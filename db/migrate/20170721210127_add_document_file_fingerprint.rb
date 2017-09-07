class AddDocumentFileFingerprint < ActiveRecord::Migration[4.2]
  def change
    add_column :documents, :document_file_fingerprint, :string
  end
end
