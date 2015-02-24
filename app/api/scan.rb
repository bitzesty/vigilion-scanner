module API
  class Scan < Grape::API

    include Grape::ActiveRecord::Extension

    version "v1", using: :header, vendor: "vs"

    params do
      requires :url, type: String
    end

    post "/scan" do
      ::Scan.create!(declared(params))
      { status: "scanning" }
    end
  end
end
