FactoryGirl.define do
  factory :account do
    name "My secured site"
    callback_url "http://secured-site.com/vigilion/callback"
  end
end
