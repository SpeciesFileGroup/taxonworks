class AddTypeToGeographicItem < ActiveRecord::Migration
  def change
    add_column :geographic_items, :type, :string
  end
end
