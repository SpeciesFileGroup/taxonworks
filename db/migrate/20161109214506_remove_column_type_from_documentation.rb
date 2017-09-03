class RemoveColumnTypeFromDocumentation < ActiveRecord::Migration[4.2]
  def change
    remove_column :documentation, :type
  end
end
