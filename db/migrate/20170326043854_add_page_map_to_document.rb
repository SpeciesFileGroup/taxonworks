class AddPageMapToDocument < ActiveRecord::Migration[4.2]
  def change
    add_column :documents, :page_map, :jsonb, default: {}
  end
end
