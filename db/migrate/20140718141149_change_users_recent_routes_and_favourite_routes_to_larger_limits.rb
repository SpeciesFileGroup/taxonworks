class ChangeUsersRecentRoutesAndFavouriteRoutesToLargerLimits < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.change :favorite_routes, :string, array: true, length: 20, default: '{}', limit: 8191
      t.change :recent_routes, :string, array: true, length: 10, default: '{}', limit: 4095
    end
  end
end