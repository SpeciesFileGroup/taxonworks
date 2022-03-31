class AddCurrentRepositoryIdToCollectionObject < ActiveRecord::Migration[6.1]
  def change
    add_column :collection_objects, :current_repository_id, :integer, index: true
  end
end
