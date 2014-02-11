class DropConfidenceFromCollectingEventUntilWeBetterUnderstandModel < ActiveRecord::Migration
  def change
    remove_column :collecting_events, :confidence_id
  end
end
