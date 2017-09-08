class AddTypeToGeographicItem < ActiveRecord::Migration[4.2]
  def change
    add_column :geographic_items, :type, :string
  end
end
