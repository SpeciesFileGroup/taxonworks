class ModifyContainers < ActiveRecord::Migration
  def change
    remove_column :containers, :container_type_id_id
    add_column :containers, :type, :string
  end
end
