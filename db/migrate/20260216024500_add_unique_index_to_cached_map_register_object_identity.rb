class AddUniqueIndexToCachedMapRegisterObjectIdentity < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  INDEX_NAME = :index_cached_map_registers_on_object_identity_unique

  def up
    dedupe_cached_map_registers_identity!

    add_index :cached_map_registers,
      [:cached_map_register_object_type, :cached_map_register_object_id],
      unique: true,
      name: INDEX_NAME,
      algorithm: :concurrently,
      if_not_exists: true
  end

  def down
    remove_index :cached_map_registers, name: INDEX_NAME if index_exists?(:cached_map_registers, name: INDEX_NAME)
  end

  private

  def dedupe_cached_map_registers_identity!
    execute <<~SQL
      WITH duplicate_groups AS (
        SELECT
          cached_map_register_object_type,
          cached_map_register_object_id,
          MIN(id) AS keeper_id
        FROM cached_map_registers
        GROUP BY cached_map_register_object_type, cached_map_register_object_id
        HAVING COUNT(*) > 1
      )
      DELETE FROM cached_map_registers cmr
      USING duplicate_groups
      WHERE
        cmr.id <> duplicate_groups.keeper_id
        AND cmr.cached_map_register_object_type = duplicate_groups.cached_map_register_object_type
        AND cmr.cached_map_register_object_id = duplicate_groups.cached_map_register_object_id;
    SQL
  end
end
