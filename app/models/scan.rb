class Scan < ActiveRecord::Base
  validates :url, presence: true, absolute_url: true
  validates_presence_of :key, :account

  enum status: %w(pending scanning clean infected error unknown)
  belongs_to :account
end
