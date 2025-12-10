FactoryBot.define do
  factory :item do
    association :user
    tag { nil }
    memo { "メモ" }

    trait :with_reminder do
      after(:create) do |item|
        create(:reminder, item: item, user: item.user)
      end
    end
  end
end
