class ScansController < ApplicationController
  before_action :authorize_admin!, only: [:admin_stats]

  # GET /scans
  def index
    @scans = current_project.scans.where("created_at > ?", 24.hours.ago).order("created_at")
    @scans = @scans.where(status: Scan.statuses[params[:status]]) if params[:status]
    @scans = @scans.where("url ilike ?", "%#{params[:url]}%") if params[:url]
  end

  def admin_stats
    @scans = Scan
      .group("DATE_TRUNC('day', created_at)")
      .order("date_trunc_day_created_at")
      .where("created_at >= ?", 90.days.ago)
    @scans = @scans.where(status: Scan.statuses[params[:status]]) if params[:status]
    @scans = @scans.count
    @scans = zeros.merge(@scans)
    render :stats
  end

  def stats
    @scans = current_project.scans
      .group("DATE_TRUNC('day', created_at)")
      .order("date_trunc_day_created_at")
      .where("created_at >= ?", 90.days.ago)
    @scans = @scans.where(status: Scan.statuses[params[:status]]) if params[:status]
    @scans = @scans.count
    @scans = zeros.merge(@scans)
    render :stats
  end

  # GET /scans/1
  def show
    @scan = current_project.scans.find(params[:id])
  end

  # POST /scans
  def create
    @scan = current_project.scans.new(scan_params)
    if !current_account.allow_more_scans?
      render json: { error: "The current account reached its monthly scan limit" }, status: 402
    elsif @scan.file.present? && !current_account.plan.allow_file_size?(@scan.file.size)
      render json: { error: "File too large for this plan" }, status: 402
    elsif @scan.save
      ScanWorker.perform_async(@scan.id)
      render :show, status: :created
    else
      render json: @scan.errors, status: :unprocessable_entity
    end
  end

  private
  def scan_params
    if params[:scan].present?
      params.require(:scan).permit(:url, :key, :file, :force)
    else
      params.permit(:url, :key, :file, :force, :do_not_unencode)
    end
  end

  def zeros
    (0..90).each_with_object({}){ |number, hash| hash[number.days.ago.beginning_of_day] = 0 }
  end
end
