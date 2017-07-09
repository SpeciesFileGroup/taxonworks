class AddDocumentDescriptionToDescriptor < ActiveRecord::Migration
  def change
    add_column :descriptors, :document_description, :text
  end
end
