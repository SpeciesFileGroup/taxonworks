class TweakingCollectingEventCached < ActiveRecord::Migration[4.2]
  def change
    rename_column :collecting_events, :cached_display, :cached
  end
end
