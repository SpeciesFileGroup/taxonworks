class AddContainerIdToSpecimen < ActiveRecord::Migration
  def change
    add_column :specimens, :container_id, :integer
  end
end
