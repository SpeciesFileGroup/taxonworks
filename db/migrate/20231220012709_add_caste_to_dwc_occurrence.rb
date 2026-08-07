class AddCasteToDwcOccurrence < ActiveRecord::Migration[6.1]
  def change
    add_column :dwc_occurrences, :caste, :string
  end
end
