class DropProjectIdFromSerials < ActiveRecord::Migration
  def change
    remove_column :serials, :project_id
  end
end
