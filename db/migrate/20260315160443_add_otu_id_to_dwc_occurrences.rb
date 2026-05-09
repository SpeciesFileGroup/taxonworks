class AddOtuIdToDwcOccurrences < ActiveRecord::Migration[8.1]
  def change
    add_column :dwc_occurrences, :otu_id, :bigint
    add_index :dwc_occurrences, :otu_id
  end
end
