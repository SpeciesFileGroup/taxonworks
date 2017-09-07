class AddPageTotalToDocument < ActiveRecord::Migration[4.2]
  def change
    add_column :documents, :page_total, :integer
  end
end
