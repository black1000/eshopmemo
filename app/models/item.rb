class Item < ApplicationRecord
  belongs_to :user

  # Itemモデルにimageという名前で画像を1枚添付できるようにする
  has_one_attached :image
end
