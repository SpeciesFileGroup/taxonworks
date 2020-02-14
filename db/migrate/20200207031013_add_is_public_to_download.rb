class AddIsPublicToDownload < ActiveRecord::Migration[6.0]
  def change
    add_column :downloads, :is_public, :boolean
  end
end
