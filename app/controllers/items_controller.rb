require "metainspector"
require "open-uri"

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
    #else
    #  @items = Item.none
    #  @reminder_days = {}
    end

    @items = @items.page(params[:page]).per(5)
  end


  def new
    @item = current_user.items.build
  end


  def create
    @item = current_user.items.build(item_params)

    begin
    # MetaInspectorを使ってURLからOGP情報を取得
    page = MetaInspector.new(@item.url)

    # タイトルが未入力ならOGPタイトルを設定
    @item.title = page.best_title if @item.title.blank?

    # 画像が未添付かつOGP画像がある場合のみ添付
    if @item.image.blank? && page.images.best.present?
      file = URI.open(page.images.best)
      @item.image.attach(
        io: file,
        filename: "ogp_image.jpg",
        content_type: "image/jpeg"
      )
    end

  rescue => e
    Rails.logger.error "OGP情報の取得に失敗しました: #{e.message}"
    flash[:alert] = "OGP情報の取得に失敗しました。URLを確認してください。"
  end

    if @item.save
      redirect_to @item, notice: "商品情報を登録しました"
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
    # タグで絞った商品
    @items = current_user.items.tagged_with(params[:tag]).order(created_at: :desc).page(params[:page]).per(5)

    # タグ専用ページにレンダリング
    render :tag
  end

  # タグ一覧
  def tags
    if current_user
      @tags = current_user.items.tag_counts.order('count DESC').limit(10)
    else
      @tags = [] # 非ログインなら空配列を返す
    end
  end


  def tag_summary
    # 全ユーザーの商品ではなく、current_userの商品に限定
    @tagged_items = current_user.items.tag_counts.sort_by(&:name).map do |tag|
      [tag.name, current_user.items.tagged_with(tag.name)]
    end.to_h
    # タグ集計は current_user の商品に限定
  end



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
  params.require(:item).permit(:url, :title, :image_url, :memo, :tag_list, :image)
end

# 本リリース時に:reminder_dateを追加
#  def item_params
#    params.require(:item).permit(:url, :title, :image_url, :memo, :reminder_date, :tag_list, :image)
    #image を追加 - Active Storageの画像添付用
#  end

end