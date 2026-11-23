# Versioning is deferred, to come back as a more general (SSSOM-like) table.
class RemoveVersionFromCompositions < ActiveRecord::Migration[8.1]
  def change
    remove_index :compositions, [:project_id, :type, :name, :version],
      unique: true, nulls_not_distinct: true,
      name: 'composition_unique_name_index'

    remove_column :compositions, :version, :text

    add_index :compositions, [:project_id, :type, :name],
      unique: true, nulls_not_distinct: true,
      name: 'composition_unique_name_index'
  end
end
