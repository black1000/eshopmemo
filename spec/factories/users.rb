FactoryBot.define do
  factory :user do
    name { "Test User" }
    email { Faker::Internet.unique.email }
    password { "password123" }
    provider { "google_oauth2" }
    uid { SecureRandom.hex(8) }
  end
end
