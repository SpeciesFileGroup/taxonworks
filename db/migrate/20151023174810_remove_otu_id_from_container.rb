class RemoveOtuIdFromContainer < ActiveRecord::Migration[4.2]
  def change
    remove_column :containers, :otu_id
  end
end
