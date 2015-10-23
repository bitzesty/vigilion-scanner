class AvRunner::Avg < AvRunner::AvBase
  def engine
    :avg
  end

  private

  def extract_message(stdout)
    lines = stdout.read.split("\n")
    # Strip filepath out of message
    lines[6]
    # first_line.gsub(/.*: /im, "")
  end

  def extract_status(wait_thr)
    exit_status = wait_thr.value.exitstatus
    { 0 => :clean,
      1 => :error, # test was interrupted by user
      2 => :error, # any error during test (e.g. cannot open file)
      3 => :error, # any warning during the scan
      4 => :infected, # PUA
      5 => :infected, # virus detected
      6 => :password_protected,
      7 => :clean, # file with hidden extension
      8 => :clean, # Macros
      9 => :infected, # archive bombs
    }[exit_status]
  end
end
