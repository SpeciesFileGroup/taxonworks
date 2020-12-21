class UseIntegerForDwCOccurrencesIndividualCount < ActiveRecord::Migration[6.0]
  def change
    change_column :dwc_occurrences, :individualCount, 'integer USING "individualCount"::integer'
  end
end
