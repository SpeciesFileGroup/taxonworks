class AddIsStaleToDwcOccurrence < ActiveRecord::Migration[7.1]
  def change
    add_column :dwc_occurrences, :is_stale, :boolean
    add_index :dwc_occurrences, :is_stale
  end
end
