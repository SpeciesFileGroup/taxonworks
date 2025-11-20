# frozen_string_literal: true

class AddMoreExportIndexes < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def up
    add_index :roles, [:role_object_type, :role_object_id],
      name: :index_roles_on_object, algorithm: :concurrently, if_not_exists: true

    add_index :roles, [:role_object_type, :role_object_id, :type],
      name: :index_roles_on_object_and_type, algorithm: :concurrently, if_not_exists: true

    add_index :roles, [:role_object_type, :role_object_id, :type, :position],
      name: :index_roles_on_object_type_position, algorithm: :concurrently, if_not_exists: true

    add_index :identifiers, [:identifier_object_type, :identifier_object_id],
      name: :index_identifiers_on_object, algorithm: :concurrently, if_not_exists: true

    add_index :biological_associations,
      [:biological_association_subject_type, :biological_association_subject_id],
      name: :index_ba_on_subject, algorithm: :concurrently, if_not_exists: true

    add_index :biological_associations,
      [:biological_association_object_type, :biological_association_object_id],
      name: :index_ba_on_object, algorithm: :concurrently, if_not_exists: true

    add_index :dwc_occurrences, [:project_id, :id],
      name: :index_dwco_on_project_id, algorithm: :concurrently, if_not_exists: true
  end

  def down
    %i[index_roles_on_object index_roles_on_object_and_type index_roles_on_object_type_position].each do |n|
      remove_index :roles, name: n if index_exists?(:roles, name: n)
    end

    remove_index :identifiers, name: :index_identifiers_on_object if index_exists?(:identifiers, name: :index_identifiers_on_object)
    remove_index :biological_associations, name: :index_ba_on_subject if index_exists?(:biological_associations, name: :index_ba_on_subject)
    remove_index :biological_associations, name: :index_ba_on_object if index_exists?(:biological_associations, name: :index_ba_on_object)
    remove_index :dwc_occurrences, name: :index_dwco_on_project_id if index_exists?(:dwc_occurrences, name: :index_dwco_on_project_id)
  end
end
