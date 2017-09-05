class AddRangedLotCategoryIdToCollectionObjects < ActiveRecord::Migration[4.2]
  def change
    add_reference :collection_objects, :ranged_lot_category, index: true
  end
end
