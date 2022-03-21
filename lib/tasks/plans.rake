namespace :plans do
  task list: :environment do
    puts " + ID\t| Name\t\t Cost\t - Size"
    Plan.find_each do |plan|
      puts " - #{plan.id}\t| #{plan.name}\t\t £ #{plan.cost} - #{plan.scans_per_month} scans/mo"
    end
  end
end
