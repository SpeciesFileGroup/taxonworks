class RemoveTypeFromContentItsNotYetNeeded < ActiveRecord::Migration
  def change
    remove_column :contents, :type
  end
end
