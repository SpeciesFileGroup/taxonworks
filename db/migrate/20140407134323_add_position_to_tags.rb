class AddPositionToTags < ActiveRecord::Migration[4.2]
  def change
    add_column :tags, :position, :integer
  end
end
