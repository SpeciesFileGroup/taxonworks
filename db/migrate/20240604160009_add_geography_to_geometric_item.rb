class AddGeographyToGeometricItem < ActiveRecord::Migration[7.1]
  def change
    add_column :geographic_items, :geography, :geometry, geographic: true, has_z: true
    # TODO: make sure I want :gist here
    add_index :geographic_items, :geography, using: :gist
  end
end
