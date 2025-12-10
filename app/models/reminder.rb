class Reminder < ApplicationRecord
  belongs_to :user
  belongs_to :item

  validates :item, presence: true
  
  validates :scheduled_date, presence: true if attribute_names.include?("scheduled_date")
end