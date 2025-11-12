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

      # カレンダー用：今月のリマインダー日を取得 仮
      #today = Date.current
      #start_date = today.beginning_of_month
      #end_date = today.end_of_month

      #@reminder_days = current_user.items
      #                             .where(reminder_date: start_date..end_date)
      #                             .group_by(&:reminder_date)
    else
      @items = Item.none
    #  @reminder_days = {}
    end

    @items = @items.page(params[:page]).per(5)
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
      redirect_to items_path, notice: "商品情報を登録しました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @referer = request.referer
  end

  def edit; end


  def update
    if @item.update(item_params)
      redirect_to @item, notice: "商品情報を更新しました"
    else
      render :edit, alert: "更新に失敗しました"
    end
  end

  def destroy
    @item.destroy
    redirect_to items_path, notice: "商品を削除しました"
  end


  def tag
    @tag = current_user.tags.find(params[:id])

    # 該当タグの商品を取得
    @items = current_user.items
                         .where(tag_id: @tag.id)
                         .order(created_at: :desc)
                         .page(params[:page])
                         .per(5)

    @tags = current_user.tags.distinct.order(:name)

    render :tag
  end

  # タグ一覧
  def tags
    if current_user
      @tags = current_user.tags.order(:name)
    else
      @tags = [] # 非ログインなら空配列を返す
    end
  end


#  def tag_summary
#    # 全ユーザーの商品ではなく、current_userの商品に限定
#    @tagged_items = current_user.items.tag_counts.sort_by(&:name).map do |tag|
#      [tag.name, current_user.items.tagged_with(tag.name)]
#    end.to_h
    # タグ集計は current_user の商品に限定
#  end



  # Item#reminders (リマインダー一覧)仮
#  def reminders
#    @reminder_items = current_user.items
#                                 .where.not(reminder_date: nil)
#                                 .order(reminder_date: :asc)
#                                 .page(params[:page])
#                                 .per(6)
#  end

  # Item#memos_on_date (特定日のメモ/カレンダー詳細)仮
#  def memos_on_date
#    date = Date.parse(params[:date])
#    @items = current_user.items.where(reminder_date: date)

#    respond_to do |format|
#      format.json { render json: @items }
#    end
#  end



private

  # current_userに関連付いた商品のみを検索
  def set_item
    @item = current_user.items.find(params[:id])
  end



def item_params
  params.require(:item).permit(:url, :title, :image_url, :memo, :image, :tag_id)
end

# 本リリース時に:reminder_dateを追加
#  def item_params
#    params.require(:item).permit(:url, :title, :image_url, :memo, :reminder_date, :tag_list, :image)
    #image を追加 - Active Storageの画像添付用
#  end

end