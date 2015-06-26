class ProjectsController < ApplicationController
  skip_before_action :authenticate!, only: :regenerate_keys
  before_action :check_api_key, except: :regenerate_keys
  before_action :find_project, only: :regenerate_keys

  # POST /projects/1/regenerate_keys
  def regenerate_keys
    @project.generate_keys
    @project.save!
    render :show, status: :ok, location: @project
  end

  private

  def find_project
    @project = Project.find(params[:id])
  end
end
