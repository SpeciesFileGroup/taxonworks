class AddBuffersToCollectionOjbect < ActiveRecord::Migration
  def change
    add_column :collection_objects, :buffered_collecting_event, :text
    add_column :collection_objects, :buffered_determinations, :text
    add_column :collection_objects, :buffered_other_labels, :text
  end
end
