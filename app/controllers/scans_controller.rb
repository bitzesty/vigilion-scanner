class ScansController < ApplicationController
  before_action :set_scan, only: [:show, :edit, :update, :destroy]

  # GET /scans
  def index
    @scans = current_account.scans
  end

  # GET /scans/1
  def show
  end

  # POST /scans
  def create
    @scan = current_account.scans.new(scan_params)

    if @scan.save
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
      params.require(:scan).permit(:url, :key)
    end
end
