class AvRunner::AvBase
  attr_reader :scan

  def initialize(scan)
    @scan = scan
  end

  def perform!
    if result = cache_hit(scan)
      result
    else
      engine_cmd = CONFIG[:engines][engine]
      engine_opts = CONFIG[:engines].fetch("#{engine}_opts", "")
      Open3.popen3("#{engine_cmd} #{engine_opts} #{scan.file_path}") do |_, stdout, _, wait_thr|
        message = extract_message(stdout)
        status = extract_status(wait_thr)
        Sidekiq.logger.info "[#{engine_name}] Message: #{message}"
        Sidekiq.logger.info "[#{engine_name}] Status #{status}"

        { status: status, message: message }
     end
    end
  end

  def cache_hit(scan)
    return false if scan.force?
    similar_scan = Scan.where(md5: scan.md5).
      where("ended_at > ?", 30.days.ago).
      where("id != ?", scan.id).
      where("#{engine}_status != 4").
      last
    if similar_scan
      { status: similar_scan.status, message: "CACHE HIT: Similar scan performed" }
    end
  end

  def engine
    raise NotImplementedError
  end

  def engine_name
    engine.to_s.upcase
  end
  def extract_message(stdout)
    raise NotImplementedError
  end

  def extract_status(wait_thr)
    raise NotImplementedError
  end
end
