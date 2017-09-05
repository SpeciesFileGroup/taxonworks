class DropSpecimenDeteriminationsTable < ActiveRecord::Migration[4.2]
  def change
    drop_table :specimen_determinations
  end
end
