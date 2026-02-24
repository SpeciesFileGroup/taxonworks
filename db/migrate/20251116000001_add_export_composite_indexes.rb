# frozen_string_literal: true

class AddExportCompositeIndexes < ActiveRecord::Migration[7.1]
  # We add indexes concurrently so we must not wrap in a transaction.
  disable_ddl_transaction!

  def up
    # Media: speed lookups by the polymorphic join used in exports
    add_index :depictions,
              [:depiction_object_id, :depiction_object_type],
              name: :index_depictions_on_object_id_and_type,
              algorithm: :concurrently,
              if_not_exists: true

    # Predicates: fast path for subject → attributes (used when staging/pivoting)
    # ID-first ordering matches the pattern used for other polymorphic indexes (e.g., roles)
    # and provides slightly more consistent performance characteristics.
    add_index :data_attributes,
              [:attribute_subject_id, :attribute_subject_type, :type],
              name: :index_data_attributes_on_subject_and_type,
              algorithm: :concurrently,
              if_not_exists: true

    # Predicates: fast path for predicate/project filtering during export
    add_index :data_attributes,
              [:controlled_vocabulary_term_id, :project_id],
              name: :index_data_attributes_on_predicate_and_project,
              algorithm: :concurrently,
              if_not_exists: true
  end

  def down
    remove_index :depictions, name: :index_depictions_on_object_id_and_type if index_exists?(:depictions, name: :index_depictions_on_object_id_and_type)
    remove_index :data_attributes, name: :index_data_attributes_on_subject_and_type if index_exists?(:data_attributes, name: :index_data_attributes_on_subject_and_type)
    remove_index :data_attributes, name: :index_data_attributes_on_predicate_and_project if index_exists?(:data_attributes, name: :index_data_attributes_on_predicate_and_project)
  end
end
