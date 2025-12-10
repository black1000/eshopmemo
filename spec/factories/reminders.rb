FactoryBot.define do
  factory :reminder do
    association :user
    association :item
    scheduled_date { Date.current + 1 }
    memo { "テストリマインダー" }
  end
end
