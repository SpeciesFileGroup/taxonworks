class AddProjectIdToIdentifiers < ActiveRecord::Migration[4.2]
  def change
    add_column :identifiers, :project_id, :integer
  end
end
