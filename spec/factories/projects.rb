FactoryBot.define do
  factory :project do
    sequence(:name) { |n| "project_#{n}" }
    callback_url { "http://secured-site.com/vigilion/callback" }
    account { association :account, strategy: :create }
  end
end
