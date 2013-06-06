class RemoveContainerIdFromSpecimens < ActiveRecord::Migration
  def change
    remove_column :specimens, :container_id
  end
end
