class AddIndexOnCurrentRepositoryId < ActiveRecord::Migration[6.1]
  def change
    add_index :collection_objects, :current_repository_id
  end
end
