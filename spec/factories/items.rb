FactoryBot.define do
  factory :item do
    memo {"テストメモ"}
    association :user
    tag { nil }
  end
end