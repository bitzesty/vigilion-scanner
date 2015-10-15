FactoryGirl.define do
  factory :plan do
    name "MyString"
    cost 9.99
    file_size_limit 1
    scans_per_month 1

    trait :no_scans_limit do
      scans_per_month nil
    end

    trait :no_size_limit do
      file_size_limit nil
    end
  end
end
