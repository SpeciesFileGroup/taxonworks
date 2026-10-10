# frozen_string_literal: true

class AddProjectIdAndObjectTypeIndexToIdentifiers < ActiveRecord::Migration[8.1]
  # We add indexes concurrently so we must not wrap in a transaction.
  disable_ddl_transaction!

  def up
    # Speeds up the project-scoped DISTINCT identifier_object_type lookup in
    # /annotations/types and Identifier::Filter#identifier_object_type_facet,
    # previously a sequential scan of the whole identifiers table.
    add_index :identifiers,
              [:project_id, :identifier_object_type],
              name: :index_identifiers_on_project_id_and_object_type,
              algorithm: :concurrently,
              if_not_exists: true
  end

  def down
    remove_index :identifiers, name: :index_identifiers_on_project_id_and_object_type if index_exists?(:identifiers, name: :index_identifiers_on_project_id_and_object_type)
  end
end
