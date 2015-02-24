class Scan < ActiveRecord::Base
  # STATES
  # scanning - default state after we receive the file
  # clean - no viruses detected
  # infected - viruses detected
  # error - internal error (e.g. file size too large)
  enum status: %w(scanning clean infected error)

  validates :url, presence: true
end
