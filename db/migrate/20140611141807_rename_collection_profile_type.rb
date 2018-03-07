class RenameCollectionProfileType < ActiveRecord::Migration[4.2]
  def change
    rename_column :collection_profiles, :type, :collection_type
  end
end
