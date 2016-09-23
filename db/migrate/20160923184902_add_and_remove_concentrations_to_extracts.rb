class AddAndRemoveConcentrationsToExtracts < ActiveRecord::Migration
  def change
    remove_column :extracts, :quantity_concentration, :decimal

    add_column :extracts, :concentration_value, :decimal
    add_column :extracts, :concentration_unit, :string
  end
end
