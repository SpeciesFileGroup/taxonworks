class AddProjectIdToAlternateValues < ActiveRecord::Migration
  def change
    add_column :alternate_values, :project_id, :integer
  end
end
