class AddRebuildSetToDwcOccurrence < ActiveRecord::Migration[7.2]
  def change
    add_column :dwc_occurrences, :rebuild_set, :text
  end
end
