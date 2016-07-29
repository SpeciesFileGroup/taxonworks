class RemoveContainerIdFromContainerItems < ActiveRecord::Migration
  # !! this is a breaking change, if you have data in your database
  # it will not be converted
  def change
    remove_column :container_items, :container_id
  end
end
