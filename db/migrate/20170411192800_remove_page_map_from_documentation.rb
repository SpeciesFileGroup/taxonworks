class RemovePageMapFromDocumentation < ActiveRecord::Migration[4.2]
  def change
    remove_column :documentation, :page_map
  end
end
