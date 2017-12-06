class KeysController < ApplicationController
  def rotate
    @project = current_project
    @project.generate_keys
    @project.save!
    render :project, status: :created
  end
end
