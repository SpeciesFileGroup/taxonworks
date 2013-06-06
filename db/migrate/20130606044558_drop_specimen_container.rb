class DropSpecimenContainer < ActiveRecord::Migration
  def change
    drop_table :specimen_containers
  end
end
