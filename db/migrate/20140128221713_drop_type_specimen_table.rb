class DropTypeSpecimenTable < ActiveRecord::Migration[4.2]
  def change
    drop_table :type_specimens 
  end
end
