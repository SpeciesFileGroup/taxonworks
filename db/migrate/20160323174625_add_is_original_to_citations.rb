class AddIsOriginalToCitations < ActiveRecord::Migration
  def change
    add_column :citations, :is_original, :boolean, index: true
  end
end
