FactoryBot.define do
  factory :user do
    name { "Test User" }
    sequence(:email) { |n| "test#{n}@example.com" }
    password { "password123" }
    provider { "google_oauth2" }
    uid { SecureRandom.hex(10) }
  end
end