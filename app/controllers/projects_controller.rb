class ProjectsController < ApplicationController
  before_action :authorize_admin!, except: [:validate]
  before_action :find_project, only: [:regenerate_keys, :update, :show, :update_plan, :destroy]

  def index
    @projects = Project.where(account_id: params[:account_id])
  end

  def create
    @project = Project.new(create_project_params)

    if @project.save
      render :show, status: :created
    else
      render json: @project.errors, status: :unprocessable_entity
    end
  end

  def update
    if @project.update(update_project_params)
      render :show
    else
      render json: @project.errors, status: :unprocessable_entity
    end
  end

  def update_plan
    @project.plan = params[:project][:plan]
    @project.save
    render :show, status: :ok
  end

  # POST /projects/1/regenerate_keys
  def regenerate_keys
    @project.generate_keys
    @project.save!
    render :show, status: :ok
  end

  def destroy
    @project.destroy
    head :no_content
  end

  def validate
    @project = current_project
    render :show, status: :ok
  end

  private

  def find_project
    @project = Project.find(params[:id])
  end

  def create_project_params
    params.require(:project).permit(:name, :callback_url, :account_id)
  end

  def update_project_params
    params.require(:project).permit(:name, :callback_url)
  end
end
