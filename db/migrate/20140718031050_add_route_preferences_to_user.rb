class AddRoutePreferencesToUser < ActiveRecord::Migration
  def change
    add_column :users, :favorite_routes, :string, array: true, length: 20, default: '{}'
    add_column :users, :recent_routes, :string, array: true, length: 10, default: '{}'
  end
end
