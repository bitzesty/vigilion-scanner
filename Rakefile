$: << File.expand_path(File.dirname(__FILE__))
require "bundler/setup"

require "grape/activerecord/rake"

namespace :db do
  task :environment do
    require "config/environment"
  end
end
