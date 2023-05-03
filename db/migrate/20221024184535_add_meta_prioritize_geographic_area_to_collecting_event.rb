class AddMetaPrioritizeGeographicAreaToCollectingEvent < ActiveRecord::Migration[6.1]
  def change
    add_column :collecting_events, :meta_prioritize_geographic_area, :boolean
  end
end
