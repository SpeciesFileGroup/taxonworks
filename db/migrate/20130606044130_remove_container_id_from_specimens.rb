class RemoveContainerIdFromSpecimens < ActiveRecord::Migration[4.2]
  def change
    remove_column :specimens, :container_id
  end
end
