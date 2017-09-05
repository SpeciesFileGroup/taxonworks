class ImageDelDupCol < ActiveRecord::Migration[4.2]
  def change
    remove_column :images, :user_image_name
  end
end
