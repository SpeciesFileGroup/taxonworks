class AddRangedLotCategoryIdToCollectionObjects < ActiveRecord::Migration
  def change
    add_reference :collection_objects, :ranged_lot_category, index: true
  end
end
