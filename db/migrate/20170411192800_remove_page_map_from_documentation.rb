class RemovePageMapFromDocumentation < ActiveRecord::Migration
  def change
    remove_column :documentation, :page_map
  end
end
