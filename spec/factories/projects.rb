FactoryGirl.define do
  sequence :account_id do |n|
    n
  end

  factory :project do
    account_id
    plan "test"
    callback_url "http://secured-site.com/vigilion/callback"
  end
end
