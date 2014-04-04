class AddProjectIdToGeoreference < ActiveRecord::Migration
  def change

    add_column :georeferences, :project_id, :integer

  end
end
