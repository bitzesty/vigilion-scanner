FactoryBot.define do
  factory :account do
    plan { association :plan, strategy: :create }
    sequence(:name) { |n| "account#{n}" }
    alert_email { "#{name}@domain.com" }
  end
end
