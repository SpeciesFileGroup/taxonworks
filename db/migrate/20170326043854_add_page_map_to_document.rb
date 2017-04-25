class AddPageMapToDocument < ActiveRecord::Migration
  def change
    add_column :documents, :page_map, :jsonb, default: {}
  end
end
