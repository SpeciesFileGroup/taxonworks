class DropAwesomeNestedSetFromContainers < ActiveRecord::Migration
  def change

    remove_column :containers, :rgt
    remove_column :containers, :lft

    Container.connection.execute('ALTER TABLE containers ALTER COLUMN parent_id DROP NOT NULL;')

  end
end
