class RemoveColumnTypeFromDocumentation < ActiveRecord::Migration
  def change
    remove_column :documentation, :type
  end
end
