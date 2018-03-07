class UpdateUserRecentRoutes < ActiveRecord::Migration[4.2]
  def change
    remove_column :users, :recent_routes, :string, array: true, default: []
    add_column :users, :footprints, :json, default: {}
  end
end
