$: << File.expand_path(File.dirname(__FILE__))
require 'config/environment'
require 'service'


use ActiveRecord::ConnectionAdapters::ConnectionManagement

run Service::App
