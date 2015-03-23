require "securerandom"

class Account < ActiveRecord::Base
  validates_presence_of :name, :callback_url
  before_create :set_auth_token
  has_many :scans

  def login
  end

  private

  def set_auth_token
    begin
      self.api_key = generate_api_key
    end while self.class.exists?(api_key: api_key)
  end

  def generate_api_key
    SecureRandom.uuid.gsub(/\-/, '')
  end
end
