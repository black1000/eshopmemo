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

    if @item.save
      redirect_to @item, notice: "商品情報を登録しました"
    else
      render :new, alert: "保存に失敗しました"
    end
  end

  def show
    @referer = request.referer
  end

  def edit
  end


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
  # 来週以降のタスクで対応する予定の属性を一旦除外（:urlのみ許可）
  params.require(:item).permit(:url)
end

#  def item_params
#    params.require(:item).permit(:url, :title, :image_url, :memo, :reminder_date, :tag_list, :image)
    #image を追加 - Active Storageの画像添付用
#  end

end