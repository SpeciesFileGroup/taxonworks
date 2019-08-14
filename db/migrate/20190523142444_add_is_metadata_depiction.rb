class AddIsMetadataDepiction < ActiveRecord::Migration[5.2]
  def change
    add_column :depictions, :is_metadata_depiction, :boolean
  end
end
