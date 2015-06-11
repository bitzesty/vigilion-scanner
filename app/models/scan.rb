class Scan < ActiveRecord::Base
  validates :url, presence: true, absolute_url: true
  validates_presence_of :key

  enum status: %w(pending clean infected error unknown)
  belongs_to :account
end
