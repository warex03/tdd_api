FactoryBot.define do
  factory :article do
    sequence(:title) { |n| "Article #{n}" }
    sequence(:content) { |n| "Unique content #{n}" }
    sequence(:slug) { |n| "article-#{n}" }
  end
end
