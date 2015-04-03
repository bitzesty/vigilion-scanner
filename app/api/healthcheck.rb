module API
  class Healthcheck < Grape::API
    include Grape::ActiveRecord::Extension

    namespace :healthcheck do
      get do
        content_type "text/plain"
        body "scanning: #{::Scan.scanning.count}"
      end
    end
  end
end
