class Item < ApplicationRecord
  belongs_to :user
  belongs_to :tag, optional: true
  attr_accessor :tag_name

  # Active Storage で画像ファイルを添付
  has_one_attached :image, dependent: :purge_later

  #タグ付け機能(複数タグ対応)
  # acts_as_taggable_on :tags
end
