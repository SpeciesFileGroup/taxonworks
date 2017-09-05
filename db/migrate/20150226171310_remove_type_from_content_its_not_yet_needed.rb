class RemoveTypeFromContentItsNotYetNeeded < ActiveRecord::Migration[4.2]
  def change
    remove_column :contents, :type
  end
end
