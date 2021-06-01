class RemoveQuantificationFromExtract < ActiveRecord::Migration[6.0]
  def change
    remove_column :extracts, :quantity_value
    remove_column :extracts, :quantity_unit

    remove_column :extracts, :concentration_value
    remove_column :extracts, :concentration_unit
  end
end
