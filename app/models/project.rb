class Project < ActiveRecord::Base
  has_many :scans

  validates :account_id, presence: true
  validates :access_key_id, uniqueness: true
  validates :callback_url, absolute_url: true, presence: true
  attr_encrypted :secret_access_key

  before_create :generate_keys

  def generate_keys
    self.access_key_id = SecureRandom.uuid
    self.secret_access_key = SecureRandom.base64(36)
  end
end
