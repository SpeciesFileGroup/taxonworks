class AddCachedGeoToCollectingEvent < ActiveRecord::Migration[4.2]
  def change
    add_column :collecting_events, :cached_level0_geographic_name, :string, index: true
    add_column :collecting_events, :cached_level1_geographic_name, :string, index: true
    add_column :collecting_events, :cached_level2_geographic_name, :string, index: true

  end
end
