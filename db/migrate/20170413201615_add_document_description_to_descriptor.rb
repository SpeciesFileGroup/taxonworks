class AddDocumentDescriptionToDescriptor < ActiveRecord::Migration[4.2]
  def change
    add_column :descriptors, :document_description, :text
  end
end
