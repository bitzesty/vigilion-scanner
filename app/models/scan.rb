class Scan < ActiveRecord::Base
  # STATES
  # scanning - default state after we receive the file
  # clean - no viruses detected
  # infected - viruses detected
  # error - internal error (e.g. file size too large)
  enum status: %w(scanning clean infected error)

  validates :url, presence: true

  def to_s
    "#{status} :: #{id} :: #{url}"
  end

  def virus_check
    # download file to tmp dir
    # take checksums
    # scan file with clamav
    # parse results
    # update status
  end
end
