class DropSpecimensRelatedTablesForRefactoring < ActiveRecord::Migration
  def change
    drop_table :specimens
  end
end
