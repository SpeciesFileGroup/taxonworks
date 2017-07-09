class RemoveDocumentDescriptionFromDescriptors < ActiveRecord::Migration
  def change
    remove_column :descriptors, :document_description
  end
end
