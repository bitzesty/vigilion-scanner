class AvRunner::Clamav < AvRunner::AvBase
  def engine
    :clamav
  end

  private

  def extract_message(stdout)
    first_line = stdout.read.split("\n")[0]
    # Strip filepath out of message
    first_line.gsub(/.*: /im, '')
  end

  def extract_status(wait_thr)
    exit_status = wait_thr.value.exitstatus
    { 0 => :clean, 1 => :infected, 2 => :error }[exit_status]
  end
end
