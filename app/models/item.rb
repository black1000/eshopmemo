class Item < ApplicationRecord
  belongs_to :user
  belongs_to :tag, optional: true

  # Active Storage で画像ファイルを添付
  has_one_attached :image

  #タグ付け機能
  # acts_as_taggable_on :tags
end
