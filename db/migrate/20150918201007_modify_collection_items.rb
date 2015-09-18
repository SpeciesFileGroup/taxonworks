class ModifyCollectionItems < ActiveRecord::Migration
  def change
    remove_column :loan_items, :collection_object_id
    remove_column :loan_items, :container_id
    add_reference :loan_items, :loan_item_object, polymorphic: true
    add_column :loan_items, :total, :integer
  end
end
