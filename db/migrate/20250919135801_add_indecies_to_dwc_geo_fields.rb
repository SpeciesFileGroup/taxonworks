class AddIndeciesToDwcGeoFields < ActiveRecord::Migration[7.2]
  def change
    # !! This might have to be rolled back if it impacts write performance significantly- which it might for bulk re-index. !!
    add_index :dwc_occurrences, :country
    add_index :dwc_occurrences, :stateProvince
    add_index :dwc_occurrences, :county
  end
end
