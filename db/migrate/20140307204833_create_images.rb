class CreateImages < ActiveRecord::Migration
  def change
    create_table :images do |t|
=begin
      t.string :image_file_file_name           # paperclip column
      t.string :image_file_content_type        # paperclip column
      t.string :image_file_file_size           # paperclip column
      t.string :image_file_updated_at          # paperclip column
      t.string :original_md5
      t.string :original_height
      t.string :original_width

      #-----------
      t.string :big
      t.string :medium
      t.string :thumb
=end

      t.string :user_file_name
      t.integer :height
      t.integer :width
      t.string  :image_file_fingerprint # paperclip MD5
      t.string  :user_image_name
      t.integer :created_by_id
      t.integer :modified_by_id
      t.integer :project_id
      t.timestamps

    end
  end

=begin
  def self.up
    add_attachment :images, :image_file
  end

  def self.down
    remove_attachment :images, :image_file

  end
=end
end

