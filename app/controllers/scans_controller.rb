class ScansController < ApplicationController
  # GET /scans
  def index
    @scans = current_project.scans.where("created_at > ?", 24.hours.ago).order("created_at")
    @scans = @scans.where(status: Scan.statuses[params[:status]]) if params[:status]
    @scans = @scans.where("url ilike ?", "%#{params[:url]}%") if params[:url]
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

    if @scan.save
      ScanWorker.perform_async(id: @scan.id)
      render :show, status: :created
    else
      render json: @scan.errors, status: :unprocessable_entity
    end
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def scan_params
    params.require(:scan).permit(:url, :key, :file, :force)
  end

  def zeros
    (0..90).each_with_object({}){ |number, hash| hash[number.days.ago.beginning_of_day] = 0 }
  end
end
