FactoryGirl.define do
  factory :scan do
    url "http://secured-site.com/file.zip"
    key "file"
    account
  end
end
