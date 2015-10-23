class RemoveOtuIdFromContainer < ActiveRecord::Migration
  def change
    remove_column :containers, :otu_id
  end
end
