class DropSpecimenDeteriminationsTable < ActiveRecord::Migration
  def change
    drop_table :specimen_determinations
  end
end
