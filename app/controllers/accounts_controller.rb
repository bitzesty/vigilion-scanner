class AccountsController < ApplicationController
  skip_before_filter :authenticate!
  before_action :set_account, only: [:show, :edit, :update, :regenerate_keys, :destroy]

  # GET /accounts
  def index
    @accounts = Account.all
  end

  # GET /accounts/1
  def show
  end

  # POST /accounts
  def create
    @account = Account.new(account_params)

    if @account.save
      render :show, status: :created, location: @account
    else
      render json: @account.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /accounts/1
  def update
    if @account.update(account_params)
      render :show, status: :ok, location: @account
    else
      render json: @account.errors, status: :unprocessable_entity
    end
  end

  # POST /accounts/1/regenerate_keys
  def regenerate_keys
    @account.generate_keys
    @account.save!
    render :show, status: :ok, location: @account
  end

  # DELETE /accounts/1
  def destroy
    @account.destroy
    head :no_content
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_account
      @account = Account.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def account_params
      params.require(:account).permit(:name, :callback_url)
    end
end
