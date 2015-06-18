class ScansController < ApplicationController
  before_action :set_scan, only: [:show, :edit, :update, :destroy]

  # GET /scans
  def index
    @scans = current_account.scans
  end

  def total
    @scans = current_account.scans
      .group("DATE_TRUNC('minute', created_at)")
      .order("date_trunc_minute_created_at")
      .where("created_at >= ?", 24.hours.ago)
      .count

    @scans = zeros.merge(@scans)
    render :stats
  end

  def infected
    @scans = current_account.scans.infected
      .group("DATE_TRUNC('minute', created_at)")
      .order("date_trunc_minute_created_at")
      .where("created_at >= ?", 24.hours.ago)
      .count

    @scans = zeros.merge(@scans)
    render :stats
  end

  def response_time
    @scans = current_account.scans
      .select("EXTRACT(EPOCH FROM (ended_at - started_at)) * 1000 AS response_time, DATE_TRUNC('minute', created_at) as created_at")
      .where("created_at >= ?", 24.hours.ago)
      .order("created_at")
  end

  def kilobytes_processed
    @scans = current_account.scans
      .select("SUM(file_size)/1024 AS file_size, DATE_TRUNC('minute', created_at) AS date_trunc_minute_created_at")
      .group("date_trunc_minute_created_at")
      .where("created_at >= ?", 24.hours.ago)
      .order("date_trunc_minute_created_at")
  end

  # GET /scans/1
  def show
  end

  # POST /scans
  def create
    @scan = current_account.scans.new(scan_params)

    if @scan.save
      ScanWorker.perform_async(id: @scan.id)
      render :show, status: :created, location: @scan
    else
      render json: @scan.errors, status: :unprocessable_entity
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_scan
    @scan = current_account.scans.find(params[:id])
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
