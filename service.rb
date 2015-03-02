module Service
  class App < Grape::API
    rescue_from ActiveRecord::RecordNotFound do |e|
      rack_response({error: "These aren't the droids you're looking for..."}.to_json, 404)
    end

    format :json

    rescue_from Grape::Exceptions::ValidationErrors do |e|
      rack_response e.to_json, 400
    end

    mount API::Scan
  end
end
