class Scan < ActiveRecord::Base
  ENGINES = [:clamav, :eset, :avg]
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

  before_create :assign_engines
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

  def complete! statuses, results
    statuses.each do |engine, status|
      self.public_send("#{engine}_status=", status)
    end
    # results?
    # self.result = result
    self.ended_at = Time.now
    save!
  end

  def engines
    ENGINES.select { |e| public_send(e) }
  end

  private

  def file_to_write?
    @file.present?
  end

  def write_file
    File.open(file_path, "wb") { |f| f.write(@file.read) } if file_to_write?
  end

  def assign_engines
    ENGINES.each do |engine|
      self.public_send("#{engine}=", account.plan.public_send(engine))
    end
  end
end
