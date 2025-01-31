class RenameDwcOccurrenceIsStaleIsFlaggedForRebuild < ActiveRecord::Migration[7.2]
  def change
    rename_column :dwc_occurrences, :is_stale, :is_flagged_for_rebuild
  end
end
