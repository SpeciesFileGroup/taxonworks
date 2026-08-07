class AddIndexToCollectionObjectBuffereds < ActiveRecord::Migration[6.1]
  def change
    add_index :collection_objects, :buffered_determinations
    add_index :collection_objects, :buffered_other_labels
    add_index :collection_objects, :buffered_collecting_event
  end
end
