class AddZBooleansToGeoreference < ActiveRecord::Migration
  def change

    add_column :georeferences, :is_undefined_z, :boolean
    add_column :georeferences, :is_median_z, :boolean

  end
end
