class AddAttachmentImageFileToImages < ActiveRecord::Migration
  def self.up
    change_table :images do |t|
      t.attachment :image_file
    end
  end

  def self.down
    drop_attached_file :images, :image_file
  end
end
