class RemoveDocumentDescriptionFromDescriptors < ActiveRecord::Migration[4.2]
  def change
    remove_column :descriptors, :document_description
  end
end
