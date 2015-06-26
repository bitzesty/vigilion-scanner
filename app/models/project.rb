class Project < ActiveRecord::Base
  belongs_to :account

  has_many :scans

  validates :callback_url, presence: true
  validates :access_key_id, uniqueness: true
  attr_encrypted :secret_access_key

  before_create :generate_keys

  def generate_keys
    self.access_key_id = SecureRandom.uuid
    self.secret_access_key = SecureRandom.base64(36)
  end
end
