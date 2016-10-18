class AddPositionToDepiction < ActiveRecord::Migration
  def change
    add_column :depictions, :position, :integer
  end
end
