class AddContainerIdtoContainerLabels < ActiveRecord::Migration
  def change
    add_column :container_labels, :container_id, :integer
    add_index :container_labels, :container_id
  end
end
