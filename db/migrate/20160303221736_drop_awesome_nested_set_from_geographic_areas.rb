class DropAwesomeNestedSetFromGeographicAreas < ActiveRecord::Migration[4.2]
  def change

    remove_column :geographic_areas, :lft
    remove_column :geographic_areas, :rgt

    GeographicArea.connection.execute('ALTER TABLE geographic_areas ALTER COLUMN parent_id DROP NOT NULL;')

  end
end
