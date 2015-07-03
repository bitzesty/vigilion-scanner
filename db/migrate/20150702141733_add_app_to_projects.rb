class AddAppToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :app, :string
    add_column :projects, :uuid, :string
  end
end
