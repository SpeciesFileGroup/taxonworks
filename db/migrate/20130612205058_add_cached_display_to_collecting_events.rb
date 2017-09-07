class AddCachedDisplayToCollectingEvents < ActiveRecord::Migration[4.2]
  def change
    add_column :collecting_events, :cached_display, :text
  end
end
