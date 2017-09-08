class AddCollectionProfileType < ActiveRecord::Migration[4.2]
  def change
    add_column :collection_profiles, :type, :string
  end
end
