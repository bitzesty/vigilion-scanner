class Scan < ActiveRecord::Base
  validates :url, presence: true

  STATES = %w(scanning clean infected error)
  # STATES
  # scanning - default state after we receive the file
  # clean - no viruses detected
  # infected - viruses detected
  # error - internal error (e.g. file size too large)
end
