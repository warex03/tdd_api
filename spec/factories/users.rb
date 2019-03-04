FactoryBot.define do
  factory :user do
    sequence(:login) { |n| "User #{n}" }
    name { "Sample name" }
    url { "http://example.com" }
    avatar_url { "http://avatar.example.com" }
    provider { "github" }
  end
end
