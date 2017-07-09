class AddPositionToDescriptor < ActiveRecord::Migration
  def change
    add_column :descriptors, :position, :integer
  end
end
