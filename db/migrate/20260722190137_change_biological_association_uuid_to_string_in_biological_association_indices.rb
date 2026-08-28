class ChangeBiologicalAssociationUuidToStringInBiologicalAssociationIndices < ActiveRecord::Migration[8.1]
  def up
    change_column :biological_association_indices, :biological_association_uuid, :string

    # The column was previously an integer, silently truncating the cached
    # UUID string (e.g. "e516b0f0-..." became 0). Recompute it from the
    # identifiers table, mirroring BiologicalAssociation#uuid (uuids.first&.cached).
    execute <<~SQL
      UPDATE biological_association_indices bai
      SET biological_association_uuid = sub.cached
      FROM (
        SELECT DISTINCT ON (identifier_object_id) identifier_object_id, cached
        FROM identifiers
        WHERE identifier_object_type = 'BiologicalAssociation'
          AND type LIKE 'Identifier::Global::Uuid%'
        ORDER BY identifier_object_id, position ASC
      ) sub
      WHERE bai.biological_association_id = sub.identifier_object_id
    SQL
  end

  def down
    execute 'UPDATE biological_association_indices SET biological_association_uuid = NULL'
    change_column :biological_association_indices, :biological_association_uuid, :integer
  end
end
