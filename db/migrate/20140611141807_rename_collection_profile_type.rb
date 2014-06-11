class RenameCollectionProfileType < ActiveRecord::Migration
  def change
    rename_column :collection_profiles, :type, :collection_type
  end
end
