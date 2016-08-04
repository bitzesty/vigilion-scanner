class HealthcheckController < ActionController::Base
  def perform
    file = "#{Rails.root}/CLAM_VERSION"
    updated_at = if File.exists?(file)
      `cat #{file}`.chomp
    else
      "unknown"
    end
    render json: {clamav: updated_at}
  end
end
