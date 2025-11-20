class Item < ApplicationRecord
  belongs_to :user
  belongs_to :tag, optional: true
  attr_accessor :tag_name

  validates :memo, length: {maximum: 30}, allow_blank: true
  
  

  has_one :reminder, dependent: :destroy
  accepts_nested_attributes_for :reminder, allow_destroy: true

  # Active Storage で画像ファイルを添付
  has_one_attached :image, dependent: :purge_later

  #タグ付け機能(複数タグ対応)
  # acts_as_taggable_on :tags
end
