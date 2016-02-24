class ModifyUserFavoriteRoutes < ActiveRecord::Migration
  def change
    remove_column :users, :favorite_routes
    add_column :users, :hub_favorites, :json
  end
end
