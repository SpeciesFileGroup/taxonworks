class AddIsPublicToDocuments < ActiveRecord::Migration[6.0]
  def change
    add_column :documents, :is_public, :boolean
  end
end
