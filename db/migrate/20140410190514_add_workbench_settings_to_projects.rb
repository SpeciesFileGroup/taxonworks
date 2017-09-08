class AddWorkbenchSettingsToProjects < ActiveRecord::Migration[4.2]
  def change
    add_column :projects, :workbench_settings, :hstore
  end
end
