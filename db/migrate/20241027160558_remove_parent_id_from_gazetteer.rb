class RemoveParentIdFromGazetteer < ActiveRecord::Migration[7.1]
  def change
    remove_column :gazetteers, :parent_id, :integer
  end
end
