class Project < ActiveRecord::Base
  belongs_to :account
  has_many :scans, dependent: :destroy

  validates :name, :account_id, presence: true

  validates :callback_url, absolute_url: true, presence: true

  before_create :generate_keys

  def generate_keys
    self.access_key_id = 'VIGIL' + SecureRandom.urlsafe_base64(20)
    self.secret_access_key = 'LION' + SecureRandom.urlsafe_base64(36)
    true
  end

  def self.regenerate_keys
    all.map do |project|
      project.generate_keys
      project.save
    end
  end
end
