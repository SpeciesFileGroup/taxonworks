# frozen_string_literal: true

class AddMoreExportIndexes < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def up
    # Note: Basic polymorphic indexes (id, type) already exist from 2015 migration.
    # Benchmark testing showed no meaningful performance difference between (id, type) and (type, id) ordering,
    # so we keep the existing indexes and only add the compound index with position.

    add_index :roles, [:role_object_id, :role_object_type, :type, :position],
      name: :index_roles_on_object_type_position, algorithm: :concurrently, if_not_exists: true

    add_index :dwc_occurrences, [:project_id, :id],
      name: :index_dwco_on_project_id, algorithm: :concurrently, if_not_exists: true
  end

  def down
    remove_index :roles, name: :index_roles_on_object_type_position if index_exists?(:roles, name: :index_roles_on_object_type_position)
    remove_index :dwc_occurrences, name: :index_dwco_on_project_id if index_exists?(:dwc_occurrences, name: :index_dwco_on_project_id)
  end
end
