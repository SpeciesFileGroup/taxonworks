class DropSpecimensRelatedTablesForRefactoring < ActiveRecord::Migration[4.2]
  def change
    drop_table :specimens
  end
end
