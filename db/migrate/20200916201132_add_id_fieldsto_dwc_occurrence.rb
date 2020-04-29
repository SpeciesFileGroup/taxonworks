class AddIdFieldstoDwcOccurrence < ActiveRecord::Migration[6.0]
  def change
    add_column :dwc_occurrences, :identifiedByID, :string
    add_column :dwc_occurrences, :recordedByID, :string
  end
end
