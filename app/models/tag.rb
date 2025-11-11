class Tag < ApplicationRecord
  belongs_to :user
  has_many :items, dependent: :nullify
  validates :name, presence: true, uniqueness: { scope: :user_id }
end
