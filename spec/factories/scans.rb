FactoryGirl.define do
  factory :scan do
    url "https://s3.amazonaws.com/vigilion-load-test/eicar.com"
    key "file"
    project
  end
end
