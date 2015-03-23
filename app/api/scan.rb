module API
  class Scan < Grape::API
    include Grape::ActiveRecord::Extension

    version "v1", using: :header, vendor: "vs"

    helpers do
      def authenticate!
        error!("Unauthorized. Invalid token", 401) unless authenticated?
      end

      def authenticated?
          Account.exists?(api_key: get_authorization_token)
      end

      def get_authorization_token
        request.headers.try(:fetch, "X-Auth-Token", nil)
      end
    end

    before do
      authenticate!
    end

    params do
      requires :url, type: String
    end

    post "/scan" do
      scan = ::Scan.create!(declared(params))
      ::ScanJob.perform_async(id: scan.id)
      ScanMapping.representation_for(:create, scan)
    end

    get "/status/:id" do
      scan = ::Scan.find(params[:id])
      ScanMapping.representation_for(:read, scan)
    end

    get "/md5/:md5" do
      scan = ::Scan.where(md5: params[:md5]).take!
      ScanMapping.representation_for(:read, scan)
    end

    get "/sha1/:sha1" do
      scan = ::Scan.where(sha1: params[:sha1]).take!
      ScanMapping.representation_for(:read, scan)
    end

    get "/sha256/:sha256" do
      scan = ::Scan.where(sha256: params[:sha256]).take!
      ScanMapping.representation_for(:read, scan)
    end
  end
end
