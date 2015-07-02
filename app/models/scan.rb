class Scan < ActiveRecord::Base
  attr_accessor :file

  enum status: %w(pending scanning clean infected error)
  belongs_to :account

  validates :url, absolute_url: true
  validates_presence_of :key, :account
  validates_presence_of :url, on: :create, unless: :file_to_write?

  after_create :write_file
  before_destroy :delete_file

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

  def complete! status, result
    self.status = status
    self.result = result
    self.ended_at = Time.now
    save!
  end

  private

  def file_to_write?
    @file.present?
  end

  def write_file
    File.open(file_path, "wb") { |f| f.write(@file.read) } if file_to_write?
  end
end
