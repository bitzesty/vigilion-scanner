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

    get "/status/:id" do
      scan = ::Scan.find(params[:id])
      { id: scan.id,
        url: scan.url,
        status: scan.status,
        message: scan.message,
        md5: scan.md5,
        sha1: scan.sha1,
        duration: scan.duration
      }
    end
  end
end
