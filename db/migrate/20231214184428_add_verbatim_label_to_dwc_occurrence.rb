class AddVerbatimLabelToDwcOccurrence < ActiveRecord::Migration[6.1]
  def change
    add_column :dwc_occurrences, :verbatimLabel, :text
  end
end
