class AddColumnPreparationTypeIdToCollectionObject < ActiveRecord::Migration
  def change
    add_column :collection_objects, :preparation_type_id, :integer
  end
end
