class AddIsOriginalToCitations < ActiveRecord::Migration[4.2]
  def change
    add_column :citations, :is_original, :boolean, index: true
  end
end
