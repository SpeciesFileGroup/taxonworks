class CleanupPreviousSpecimenTables < ActiveRecord::Migration[4.2]
  def change
    drop_table :specimen_lots
    drop_table :specimen_individuals
  end
end
