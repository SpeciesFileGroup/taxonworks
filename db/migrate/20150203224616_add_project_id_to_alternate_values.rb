class AddProjectIdToAlternateValues < ActiveRecord::Migration[4.2]
  def change
    add_column :alternate_values, :project_id, :integer
  end
end
