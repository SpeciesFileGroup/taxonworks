class AddPositionToDepiction < ActiveRecord::Migration[4.2]
  def change
    add_column :depictions, :position, :integer
  end
end
