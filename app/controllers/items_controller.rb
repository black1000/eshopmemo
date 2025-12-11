require "metainspector"
require "open-uri"
require "nokogiri"

class ItemsController < ApplicationController
  # before_action :authenticate_user!, except: [ :index ]
  before_action :set_item, only: [ :show, :edit, :update, :destroy ]
  before_action :authenticate_user!
  before_action :set_month, only: %i[index reminders]

  def index
    if current_user
      # ログインユーザーの商品のみを表示
      @items = current_user.items.order(created_at: :desc)

      # カレンダー用
      today = @month
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

    @items = @items.page(params[:page]).per(8)

    @tags = current_user.tags
                    .left_joins(:items)
                    .group("tags.id")
                    .having("COUNT(items.id) > 0")
                    .order(:name)
  end


  def new
    @item = current_user.items.build
  end


  def create
    downloaded_image = nil

    # 新規タグ作成
    permitted = item_params
    tag_name = permitted.delete(:tag_name)
    @item = current_user.items.build(permitted)

     if tag_name.present?
      @item.tag = current_user.tags.find_or_create_by!(name: tag_name)
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
        Rails.logger.warn t("items.create.image_not_found_log", url: @item.url)
      end

    rescue => e
      Rails.logger.error t("items.create.image_fetch_failed_log", message: e.message)
      flash[:alert] = t("items.create.image_fetch_failed")
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

  redirect_to items_path, notice: t("items.create.success")
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

  tag_name = update_params.delete(:tag_name)

  if tag_name.present?
  tag = current_user.tags.find_or_create_by!(name: tag_name)
  update_params[:tag_id] = tag.id
  end

  if @item.update(update_params)

    @item.reload
    @item.reminder&.reload

    redirect_to @item, notice: t("items.update.success")
  else
    flash.now[:alert] = t("items.update.fail")
    render :edit, status: :unprocessable_entity
  end
end

  def destroy
    tag = @item.tag

    @item.destroy

    if tag.present? && tag.items.empty?
      tag.destroy
    end

    redirect_to items_path, notice: t("items.destroy.success")
  end


  def tag
    @tag = current_user.tags.find(params[:id])

    # 該当タグの商品を取得
    @items = current_user.items
                         .where(tag_id: @tag.id)
                         .order(created_at: :desc)
                         .page(params[:page])
                         .per(6)

    # 商品が1件以上あるタグのみ表示
    @tags = current_user.tags
                        .left_joins(:items)
                        .group("tags.id")
                        .having("COUNT(items.id) > 0")
                        .order(:name)

    render :tag
  end

  # タグ一覧
  def tags
    if current_user
      @tags = current_user.tags
                          .left_joins(:items)
                          .group("tags.id")
                          .having("COUNT(items.id) > 0")
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
    redirect_to @item, notice: t("reminders.create.success")
  else
    flash[:alert] = t("reminders.create.failure")
    redirect_to @item
  end
end

def reminders
  # 表示する月を決定（パラメータがあればその月、なければ今月）
  @month = if params[:month].present?
             Date.strptime(params[:month], "%Y-%m")
  else
             Date.current
  end

  start_date = @month.beginning_of_month
  end_date   = @month.end_of_month

  # 予定一覧用（一覧テーブル・リスト用）
  @reminders = current_user.reminders
                           .includes(:item)
                           .order(scheduled_date: :asc)
                           .page(params[:page]).per(8)

  # カレンダー用（その月の全予定）
  month_reminders = current_user.reminders
                                .where(scheduled_date: start_date..end_date)
                                .includes(:item)

  @reminder_days = month_reminders.group_by(&:scheduled_date)
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

def set_month
  @month =
    if params[:month].present?
      Date.strptime(params[:month], "%Y-%m")
    else
      Date.current
    end
rescue ArgumentError
  @month = Date.current
end


  def set_item
    @item = current_user.items.find(params[:id])
  end


def item_params # item に必要なカラムだけを許可して取得
  whitelisted = params.require(:item).permit(
    :url, :title, :image_url, :memo, :image, :tag_id, :tag_name,
    reminder_attributes: [ :id, :scheduled_date, :memo, :_destroy, :user_id ]
  )

  if whitelisted[:reminder_attributes].present?
  ra = whitelisted[:reminder_attributes]

  # 日付/メモが空ならネスト自体を捨てる
  if ra[:scheduled_date].blank? && ra[:memo].blank? && ra[:_destroy].blank?
    whitelisted.delete(:reminder_attributes)
  else
    whitelisted[:reminder_attributes] = ra.merge(user_id: current_user.id)
  end
  end

  whitelisted # 最終的な permit 済みパラメータを返す
end
end
