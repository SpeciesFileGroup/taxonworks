class CleanupPreviousSpecimenTables < ActiveRecord::Migration
  def change
    drop_table :specimen_lots
    drop_table :specimen_individuals
  end
end
