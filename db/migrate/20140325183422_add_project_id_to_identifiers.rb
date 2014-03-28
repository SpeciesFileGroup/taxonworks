class AddProjectIdToIdentifiers < ActiveRecord::Migration
  def change
    add_column :identifiers, :project_id, :integer
  end
end
