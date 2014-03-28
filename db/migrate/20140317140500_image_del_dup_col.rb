class ImageDelDupCol < ActiveRecord::Migration
  def change
    remove_column :images, :user_image_name
  end
end
