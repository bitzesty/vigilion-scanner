class Scan < ActiveRecord::Base
  validates :url, presence: true
end
