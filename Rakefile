$: << File.expand_path(File.dirname(__FILE__))
require "config/environment"
require "bundler/setup"

require "grape/activerecord/rake"
Rake.add_rakelib "lib/tasks"

namespace :db do
  task :environment do
    require "config/environment"
  end
end
