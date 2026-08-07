# frozen_string_literal: true

class AddFingerprintCompositeIndexes < ActiveRecord::Migration[8.1]
  # We add indexes concurrently so we must not wrap in a transaction.
  disable_ddl_transaction!

  def up
    # Speeds up Image's `validates_uniqueness_of :image_file_fingerprint,
    # scope: :project_id`, previously an unindexed scan filtering rows one by
    # one. Fingerprint-first also covers Image#has_duplicate?/#duplicate_images,
    # which query image_file_fingerprint alone; project_id-alone queries
    # remain served by the existing index_images_on_project_id.
    add_index :images,
              [:image_file_fingerprint, :project_id],
              name: :index_images_on_fingerprint_and_project_id,
              algorithm: :concurrently,
              if_not_exists: true

    # Speeds up Document's `validates_uniqueness_of :document_file_fingerprint,
    # scope: :project_id`, previously a full sequential scan (documents had no
    # project_id index at all). project_id-first also covers the many
    # project-scoped Document listing queries (documents#index, TSV export,
    # recent documents, etc).
    add_index :documents,
              [:project_id, :document_file_fingerprint],
              name: :index_documents_on_project_id_and_fingerprint,
              algorithm: :concurrently,
              if_not_exists: true
  end

  def down
    remove_index :images, name: :index_images_on_fingerprint_and_project_id if index_exists?(:images, name: :index_images_on_fingerprint_and_project_id)
    remove_index :documents, name: :index_documents_on_project_id_and_fingerprint if index_exists?(:documents, name: :index_documents_on_project_id_and_fingerprint)
  end
end
