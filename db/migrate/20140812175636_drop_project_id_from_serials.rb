class DropProjectIdFromSerials < ActiveRecord::Migration[4.2]
  def change
    remove_column :serials, :project_id
  end
end
