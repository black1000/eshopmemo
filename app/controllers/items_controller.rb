require "metainspector"
require "open-uri"
require "nokogiri"

class ItemsController < ApplicationController
  before_action :authenticate_user!, except: [:index]
  before_action :set_item, only: [:show, :edit, :update, :destroy]


  def index
    if current_user
      # ログインユーザーの商品のみを表示
      @items = current_user.items.order(created_at: :desc)

      # カレンダー用
      today = Date.current
      start_date = today.beginning_of_month
      end_date = today.end_of_month

      reminders = current_user.reminders
                              .where(scheduled_date: start_date..end_date)
                              .includes(:item)

      @reminder_days = reminders.group_by(&:scheduled_date)
    else
      @items = Item.none
      @reminder_days = {}
    end

    @items = @items.page(params[:page]).per(10)

    @tags = current_user.tags
                    .left_joins(:items)
                    .group('tags.id')
                    .having('COUNT(items.id) > 0')
                    .order(:name)
  end


  def new
    @item = current_user.items.build
  end


  def create
    @item = current_user.items.build(item_params)
    downloaded_image = nil

      # 新規タグ作成
    if params[:item][:new_tag].present?
      new_tag = current_user.tags.find_or_create_by(name: params[:item][:new_tag])
      @item.tag = new_tag
    end

    if params[:new_tag_name].present?
  tag = current_user.tags.find_or_create_by(name: params[:new_tag_name])
  @item.tag = tag
end

    begin
      page = MetaInspector.new(@item.url, allow_redirections: :all)

      # タイトル設定
      if @item.title.blank? && page.best_title.present?
        @item.title = page.best_title.truncate(15, omission: "…")
      end

      #  画像取得の多層フォールバック
      image_url = nil

      # OGP画像
      image_url ||= page.images.best

      # HTML内の最初の画像
      if image_url.blank?
        doc = Nokogiri::HTML(URI.open(@item.url))
        first_img = doc.css("img").map { |img| img["src"] }.compact.first
        if first_img.present?
          # 相対URLを絶対URLに変換
          image_url = URI.join(@item.url, first_img).to_s rescue nil
        end
      end

      # faviconやブランドロゴ的代替
      if image_url.blank?
        favicon = doc.at("link[rel='icon']")&.[]("href") ||
                  doc.at("link[rel='shortcut icon']")&.[]("href") ||
                  doc.at("link[rel='apple-touch-icon']")&.[]("href")
        if favicon.present?
          image_url = URI.join(@item.url, favicon).to_s rescue nil
        end
      end

      # 画像をダウンロードしてActiveStorage経由でCloudinaryへ保存
      if image_url.present?
        downloaded_image = URI.open(image_url, open_timeout: 5, read_timeout: 10)
        @item.image.attach(
          io: downloaded_image,
          filename: "ogp_image_#{SecureRandom.hex(4)}.jpg",
          content_type: downloaded_image.content_type || "image/jpeg"
        )
      else
        Rails.logger.warn "画像が取得できませんでした: #{@item.url}"
      end

    rescue => e
      Rails.logger.error "OGPまたは画像の取得に失敗しました: #{e.message}"
      flash[:alert] = "画像の取得に失敗しました。URLを確認してください。"
    ensure
    end

    if @item.save
  # リマインダー日付が入力されていた場合のみ保存
  if params[:item][:scheduled_date].present?
    current_user.reminders.create!(
      item: @item,
      scheduled_date: params[:item][:scheduled_date],
      memo: params[:item][:reminder_memo]
    )
  end

  redirect_to items_path, notice: "商品情報を登録しました"
else
  render :new
end
  end

  def show
  @item = current_user.items.find(params[:id])
  
  @reminder = @item.reminder
end


  def edit
   @item.build_reminder if @item.reminder.blank?
  end


  def update
  update_params = item_params 

  if @item.update(update_params) 

    @item.reload
    @item.reminder&.reload 

    redirect_to @item, notice: "商品情報を更新しました"
  else
    flash.now[:alert] = "更新に失敗しました"
    render :edit, status: :unprocessable_entity
  end
end

  def destroy
    tag = @item.tag

    @item.destroy

    if tag.present? && tag.items.empty?
      tag.destroy
    end

    redirect_to items_path, notice: "商品を削除しました"
  end


  def tag
    @tag = current_user.tags.find(params[:id])

    # 該当タグの商品を取得
    @items = current_user.items
                         .where(tag_id: @tag.id)
                         .order(created_at: :desc)
                         .page(params[:page])
                         .per(10)

    # 商品が1件以上あるタグのみ表示
    @tags = current_user.tags
                        .left_joins(:items)
                        .group('tags.id')
                        .having('COUNT(items.id) > 0')
                        .order(:name)

    render :tag
  end

  # タグ一覧
  def tags
    if current_user
      @tags = current_user.tags
                          .left_joins(:items)
                          .group('tags.id')
                          .having('COUNT(items.id) > 0')
                          .order(:name)
    else
      @tags = [] # 非ログインなら空配列を返す
    end
    
  end


def reminder_params
  params.require(:reminder).permit(:scheduled_date, :memo)
end

def create_reminder
  @item = current_user.items.find(params[:id])
  @reminder = current_user.reminders.build(reminder_params.merge(item: @item))

  if @reminder.save
    redirect_to @item, notice: "リマインダーを追加しました"
  else
    flash[:alert] = "リマインダーの登録に失敗しました"
    redirect_to @item
  end
end

def reminders
  @reminders = current_user.reminders
                           .includes(:item)
                           .order(scheduled_date: :asc)
                           .page(params[:page]).per(10)

  @reminder_days = @reminders.group_by(&:scheduled_date)
end



def reminders_by_date
  date = Date.parse(params[:date])
  @reminders = current_user.reminders
                           .includes(:item)
                           .where(scheduled_date: date)
                           .page(params[:page]).per(6)
  @date = date
end


private


  def set_item
    @item = current_user.items.find(params[:id])
  end


def item_params # item に必要なカラムだけを許可して取得
  whitelisted = params.require(:item).permit(
    :url, :title, :image_url, :memo, :image, :tag_id,
    reminder_attributes: [:id, :scheduled_date, :memo, :_destroy, :user_id] 
  )

  if whitelisted[:reminder_attributes].present?
    reminder_attrs = whitelisted[:reminder_attributes]

    # Reminderが新規作成時（idが空）、または user_idが設定されていない場合
    if reminder_attrs[:id].blank? || reminder_attrs[:user_id].blank?
       # user_idをcurrent_user.idで上書き
       whitelisted[:reminder_attributes] = reminder_attrs.merge(user_id: current_user.id)
    end
  end

  whitelisted #最終的な permit 済みパラメータを返す
end

end