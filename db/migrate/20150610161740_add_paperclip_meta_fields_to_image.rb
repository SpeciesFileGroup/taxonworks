class AddPaperclipMetaFieldsToImage < ActiveRecord::Migration[4.2]
  def change
    add_column :images, :image_file_meta, :text
  end
end
