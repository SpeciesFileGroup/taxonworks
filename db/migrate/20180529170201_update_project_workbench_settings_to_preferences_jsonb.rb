class UpdateProjectWorkbenchSettingsToPreferencesJsonb < ActiveRecord::Migration[5.1]
  def change
    change_column :projects, :workbench_settings, :jsonb, using: 'workbench_settings::jsonb', null: false, default: '{}'
    rename_column :projects, :workbench_settings, :preferences
  end
end
