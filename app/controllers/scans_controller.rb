class ScansController < ApplicationController
  before_action :set_scan, only: [:show, :edit, :update, :destroy]

  # GET /scans
  def index
    @scans = current_account.scans
  end

  def total
    @scans = zeros.merge(current_account.scans.group("DATE(created_at)").order("date_created_at").where("created_at > ?", 30.days.ago).count)

    render :stats
  end

  def infected
    @scans = zeros.merge(current_account.scans.infected.group("DATE(created_at)").where("created_at > ?", 30.days.ago).order("date_created_at").count)
    render :stats
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
    @zeros ||= 30.downto(0)
      .map { |n| n.days.ago.to_date }
      .each_with_object({}) { |d, h| h[d] = 0 }
  end
end
