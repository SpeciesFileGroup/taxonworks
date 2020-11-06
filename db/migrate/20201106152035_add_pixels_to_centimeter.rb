class AddPixelsToCentimeter < ActiveRecord::Migration[6.0]
  def change
    add_column :images, :pixels_to_centimeter, :float
  end
end
