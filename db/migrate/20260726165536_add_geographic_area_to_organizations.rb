class AddGeographicAreaToOrganizations < ActiveRecord::Migration[8.1]
  def change
    add_reference :organizations, :geographic_area, foreign_key: true, index: true
  end
end
