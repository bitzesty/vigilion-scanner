class ScansController < ApplicationController
  before_action :set_scan, only: [:show]

  # GET /scans
  def index
    @scans = current_project.scans.where("created_at >= ?", 24.hours.ago).order("created_at")
  end

  def stats
    @scans = current_project.scans
      .group("DATE_TRUNC('minute', created_at)")
      .order("date_trunc_minute_created_at")
      .where("created_at >= ?", 24.hours.ago)
    @scans = @scans.where(status: Scan.statuses[params[:status]]) if params[:status]
    @scans = @scans.count
    @scans = zeros.merge(@scans)
    render :stats
  end

  # GET /scans/1
  def show
  end

  # POST /scans
  def create
    @scan = current_project.scans.new(scan_params)

    if @scan.save
      ScanWorker.perform_async(id: @scan.id)
      render :show, status: :created
    else
      render json: @scan.errors, status: :unprocessable_entity
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_scan
    @scan = current_project.scans.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def scan_params
    params.require(:scan).permit(:url, :key, :file)
  end

  def zeros
    @zeros ||= (24 * 60).downto(0)
      .map { |n| n.minutes.ago.beginning_of_minute }
      .each_with_object({}) { |d, h| h[d] = 0 }
  end
end
