class AddColumnPreparationTypeIdToCollectionObject < ActiveRecord::Migration[4.2]
  def change
    add_column :collection_objects, :preparation_type_id, :integer
  end
end
