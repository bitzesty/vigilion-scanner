begin
  namespace :account do
    task :create do
      puts "You should provide callback url and application name via ENV variables"
      unless ENV["VIRUS_SCANNER_ACCOUNT_NAME"].nil? || ENV["VIRUS_SCANNER_CALLBACK_URL"].nil?
        name = ENV["VIRUS_SCANNER_ACCOUNT_NAME"].dup.to_s.strip
        callback_url = ENV["VIRUS_SCANNER_CALLBACK_URL"].dup.to_s.strip

        unless name.blank? || callback_url.blank?
          if account = Account.create!(name: name, callback_url: callback_url)
            puts "Account created"
            puts "Your API key is: #{account.api_key}"
          else
            puts "Sorry, it was not possible to create new account"
          end
        end
      else
        puts "Sorry, you did not provide application name and callback url"
      end
    end
  end
end
