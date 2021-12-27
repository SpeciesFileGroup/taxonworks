class AddMetadataToGeoreference < ActiveRecord::Migration[6.1]
  def change
    add_column :georeferences, :year_georeferenced, :int
    add_column :georeferences, :month_georeferenced, :int
    add_column :georeferences, :day_georeferenced, :int
  end
end
