class AddPositionToDescriptor < ActiveRecord::Migration[4.2]
  def change
    add_column :descriptors, :position, :integer
  end
end
