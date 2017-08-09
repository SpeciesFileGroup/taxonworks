class AddDocumentFileFingerprint < ActiveRecord::Migration
  def change
    add_column :documents, :document_file_fingerprint, :string
  end
end
