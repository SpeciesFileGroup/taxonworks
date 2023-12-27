class AddDwcOccurrenceHigherClassifications < ActiveRecord::Migration[6.1]
  def change
    add_column :dwc_occurrences, :superfamily, :string
    add_column :dwc_occurrences, :subfamily, :string
    add_column :dwc_occurrences, :tribe, :string
    add_column :dwc_occurrences, :subtribe, :string
  end
end
