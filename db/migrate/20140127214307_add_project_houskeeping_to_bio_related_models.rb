class AddProjectHouskeepingToBioRelatedModels < ActiveRecord::Migration
  def change
    add_column :biological_associations_biological_associations_graphs, :project_id, :integer
  end
end
