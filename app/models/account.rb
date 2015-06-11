class Account < ActiveRecord::Base
  validates_presence_of :name, :callback_url
  validates :access_key_id, uniqueness: true
  attr_encrypted :secret_access_key

  before_create :generate_keys

  def generate_keys
    self.access_key_id = SecureRandom.uuid
    self.secret_access_key = SecureRandom.base64(36)
  end
end
