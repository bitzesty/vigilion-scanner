FactoryGirl.define do
  factory :account do
    plan
    sequence(:name) { |n| "account#{n}" }
    alert_email { "#{name}@domain.com" }
  end
end
