class UpdateDepictionToHandleSled < ActiveRecord::Migration[6.0]
  def change
    add_reference :depictions, :sled_image, foreign_key: true
    add_column :depictions, :sled_image_x_position, :integer
    add_column :depictions, :sled_image_y_position, :integer
  end
end
