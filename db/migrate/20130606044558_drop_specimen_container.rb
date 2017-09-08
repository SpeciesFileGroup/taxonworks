class DropSpecimenContainer < ActiveRecord::Migration[4.2]
  def change
    drop_table :specimen_containers
  end
end
