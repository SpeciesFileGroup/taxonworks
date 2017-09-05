class RenameCollectionProfileColumn < ActiveRecord::Migration[4.2]
  def change
    rename_column :collection_profiles, :modified_by_id, :updated_by_id
    rename_column :loan_items, :modified_by_id, :updated_by_id
    rename_column :loans, :modified_by_id, :updated_by_id
  end
end
