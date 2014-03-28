class AddCollectionProfileType < ActiveRecord::Migration
  def change
    add_column :collection_profiles, :type, :string
  end
end
