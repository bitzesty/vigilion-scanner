ActiveRecord::Base.attr_encrypted_options[:key] = Rails.application.secrets.secret_key_base
