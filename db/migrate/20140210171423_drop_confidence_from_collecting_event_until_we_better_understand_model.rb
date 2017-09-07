class DropConfidenceFromCollectingEventUntilWeBetterUnderstandModel < ActiveRecord::Migration[4.2]
  def change
    remove_column :collecting_events, :confidence_id
  end
end
