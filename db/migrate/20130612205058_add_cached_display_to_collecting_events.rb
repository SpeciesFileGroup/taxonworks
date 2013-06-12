class AddCachedDisplayToCollectingEvents < ActiveRecord::Migration
  def change
    add_column :collecting_events, :cached_display, :text
  end
end
