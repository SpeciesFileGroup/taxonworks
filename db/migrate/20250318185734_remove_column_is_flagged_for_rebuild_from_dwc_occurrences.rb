class RemoveColumnIsFlaggedForRebuildFromDwcOccurrences < ActiveRecord::Migration[7.2]
  def change
    remove_column :dwc_occurrences, :is_flagged_for_rebuild
  end
end
