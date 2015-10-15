class Account < ActiveRecord::Base
  belongs_to :plan
  has_many :projects, dependent: :destroy
  has_many :scans, through: :projects

  validates :plan_id, presence: true

  def scan_amount_this_month
    scans.where("scans.created_at > ? ", DateTime.now.beginning_of_month).count
  end

  def allow_more_scans?
    plan.allow_more_scans? scan_amount_this_month
  end
end
