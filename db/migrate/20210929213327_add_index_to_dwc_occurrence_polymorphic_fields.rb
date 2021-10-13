class AddIndexToDwcOccurrencePolymorphicFields < ActiveRecord::Migration[6.1]
  def change
    add_index :dwc_occurrences, [:dwc_occurrence_object_id, :dwc_occurrence_object_type], name: :dwc_occurrences_object_index
  end
end
