class DropTableContainerLabels < ActiveRecord::Migration[5.1]
  def change
    drop_table :container_labels
  end
end
