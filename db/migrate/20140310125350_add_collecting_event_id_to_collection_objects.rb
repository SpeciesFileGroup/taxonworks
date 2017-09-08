class AddCollectingEventIdToCollectionObjects < ActiveRecord::Migration[4.2]
  def change
    add_reference :collection_objects, :collecting_event, index: true
  end
end
