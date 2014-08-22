class TweakingCollectingEventCached < ActiveRecord::Migration
  def change
    rename_column :collecting_events, :cached_display, :cached
  end
end
