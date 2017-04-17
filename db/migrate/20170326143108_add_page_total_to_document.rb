class AddPageTotalToDocument < ActiveRecord::Migration
  def change
    add_column :documents, :page_total, :integer
  end
end
