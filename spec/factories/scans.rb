FactoryBot.define do
  factory :scan do
    transient do
      account { nil }
    end

    url { "http://www.eicar.com/eicar.com.txt" }
    key { "file" }
    project do
      if account
        association(:project, account: account, strategy: :create)
      else
        association(:project, strategy: :create)
      end
    end
  end
end
