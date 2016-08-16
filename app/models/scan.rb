class Scan < ActiveRecord::Base
  AV_STATUSES = %w(pending scanning clean infected error)
  attr_accessor :file

  enum status: AV_STATUSES
  enum clamav_status: AV_STATUSES, _prefix: :clamav
  enum avg_status: AV_STATUSES, _prefix: :avg
  enum eset_status: AV_STATUSES, _prefix: :eset

  belongs_to :project
  has_one :account, through: :project

  validates :url, absolute_url: true
  validates :key, :project, presence: true
  validates :url, presence: true, on: :create, unless: :file_to_write?

  after_create :write_file
  before_destroy :delete_file

  def url=(new_url)
    unescaped_url = Addressable::URI.unescape(new_url)
    write_attribute :url, unescaped_url
  end

  def duration
    ended_at - started_at if ended_at
  end

  def response_time
    ended_at - created_at if ended_at
  end

  def file_path
    File.join(File.expand_path("../../..", __FILE__), "tmp", id)
  end

  def file_exists?
    File.exist?(file_path)
  end

  def delete_file
    File.delete(file_path) if file_exists?
  end

  def start!
    self.status = :scanning
    self.started_at = Time.now
    save!
  end

  def av_checked!(scan_results)
    scan_results.each do |engine, result|
      self.public_send(
        "#{engine}_status=",
        result[:status]
      )
      self.public_send(
        "#{engine}_result=",
        result[:message]
      )
    end

    result = relevant_result(scan_results)
    complete!(result[:status], result[:message])
  end

  def complete!(status, result)
    self.status = status
    self.result = result
    self.ended_at = Time.now
    save!
  end

  def engines
    account.plan.engines
  end

  private

  def relevant_result(scan_results)
    infected = scan_results.values.detect do |result|
      result[:status] == :infected
    end
    return infected if infected.present?

    clean = scan_results.values.detect do |result|
      result[:status] == :clean
    end
    return clean if clean.present?

    return scan_results.values.first
  end

  def file_to_write?
    @file.present?
  end

  def write_file
    File.open(file_path, "wb") { |f| f.write(@file.read) } if file_to_write?
  end
end
