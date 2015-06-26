FactoryGirl.define do
  factory :project do
    account
    plan "test"
    callback_url "http://secured-site.com/vigilion/callback"
  end
end
