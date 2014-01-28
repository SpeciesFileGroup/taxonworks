class DropTypeSpecimenTable < ActiveRecord::Migration
  def change
    drop_table :type_specimens 
  end
end
