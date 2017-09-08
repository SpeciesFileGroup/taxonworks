class AddContainerIdToSpecimen < ActiveRecord::Migration[4.2]
  def change
    add_column :specimens, :container_id, :integer
  end
end
