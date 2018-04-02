class AddDefaultUnitsToDescriptor < ActiveRecord::Migration[5.1]
  def change
    add_column :descriptors, :default_unit, :string
  end
end
