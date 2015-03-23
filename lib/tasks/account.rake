begin
  namespace :account do
    task :create do
      puts "You will be prompted to provide callback url and application name"
      puts "Provide application name"
      name = STDIN.gets
      puts "Provide callback url"
      callback_url = STDIN.gets
      unless name.strip!.blank? || callback_url.strip!.blank?
        if account = Account.create!(name: name, callback_url: callback_url)
          puts "Account created"
          puts "Your API key is: #{account.api_key}"
        else
          puts "Sorry, it was not possible to create new account"
        end
      end
    end
  end
end
