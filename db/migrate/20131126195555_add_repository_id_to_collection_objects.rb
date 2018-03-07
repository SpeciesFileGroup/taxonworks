class AddRepositoryIdToCollectionObjects < ActiveRecord::Migration[4.2]
  def change
    add_column :collection_objects, :repository_id, :integer, index: true
  end
end
