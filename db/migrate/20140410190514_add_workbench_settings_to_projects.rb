class AddWorkbenchSettingsToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :workbench_settings, :hstore
  end
end
