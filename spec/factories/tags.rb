FactoryBot.define do
  factory :tag do
    association :user
    name { "tag-#{SecureRandom.hex(3)}" }
  end
end
