class AddPaperclipMetaFieldsToImage < ActiveRecord::Migration
  def change
    add_column :images, :image_file_meta, :text
  end
end
