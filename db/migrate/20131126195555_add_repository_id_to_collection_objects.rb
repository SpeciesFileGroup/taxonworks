class AddRepositoryIdToCollectionObjects < ActiveRecord::Migration
  def change
    add_column :collection_objects, :repository_id, :integer, index: true
  end
end
