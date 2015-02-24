module API
  class Scan < Grape::API

    include Grape::ActiveRecord::Extension

    version "v1", using: :header, vendor: "vs"

    params do
      requires :url, type: String
    end

    post "/scan" do
      scan = ::Scan.create!(declared(params))
      ::ScanJob.perform_async(id: scan.id)
      { id: scan.id, status: scan.status }
    end
  end
end
