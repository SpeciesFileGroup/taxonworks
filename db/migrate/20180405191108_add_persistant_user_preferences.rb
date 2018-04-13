class AddPersistantUserPreferences < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :preferences, :json, default: {}
  end
end
