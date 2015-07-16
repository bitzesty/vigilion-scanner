FactoryGirl.define do
  factory :project do
    sequence(:name) { |n| "project_#{n}" }
    sequence(:account_id) { |n| n }
    plan "test"
    callback_url "http://secured-site.com/vigilion/callback"
  end
end
