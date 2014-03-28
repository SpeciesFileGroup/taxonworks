class AddCollectingEventIdToCollectionObjects < ActiveRecord::Migration
  def change
    add_reference :collection_objects, :collecting_event, index: true
  end
end
