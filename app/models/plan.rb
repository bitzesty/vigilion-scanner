class Plan < ActiveRecord::Base
  MEGA_BYTE = 1024 * 1024

  scope :available_for_new_subscriptions, -> { where(available_for_new_subscriptions: true) }

  def allow_more_scans?(scan_amount_this_month)
    scans_per_month.nil? || scan_amount_this_month < scans_per_month
  end

  def allow_file_size?(size_in_bytes)
    file_size_limit.nil? || file_size_limit * MEGA_BYTE >= size_in_bytes
  end
end
