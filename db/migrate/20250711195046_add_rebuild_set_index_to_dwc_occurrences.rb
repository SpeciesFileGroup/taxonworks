class AddRebuildSetIndexToDwcOccurrences < ActiveRecord::Migration[7.2]
  def change
    add_index :dwc_occurrences, [:rebuild_set, :id]
  end
end
