class AddUniqueIndexToCachedMapItemsIdentity < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  INDEX_NAME = :index_cached_map_items_on_type_otu_gi_project

  def up
    dedupe_cached_map_items_identity!

    add_index :cached_map_items,
      [:type, :otu_id, :geographic_item_id, :project_id],
      unique: true,
      name: INDEX_NAME,
      algorithm: :concurrently,
      if_not_exists: true
  end

  def down
    remove_index :cached_map_items, name: INDEX_NAME if index_exists?(:cached_map_items, name: INDEX_NAME)
  end

  private

  def dedupe_cached_map_items_identity!
    execute <<~SQL
      WITH duplicate_groups AS (
        SELECT
          type,
          otu_id,
          geographic_item_id,
          project_id,
          MIN(id) AS keeper_id,
          SUM(COALESCE(reference_count, 0))::integer AS summed_reference_count
        FROM cached_map_items
        GROUP BY type, otu_id, geographic_item_id, project_id
        HAVING COUNT(*) > 1
      )
      UPDATE cached_map_items cmi
      SET
        reference_count = duplicate_groups.summed_reference_count,
        updated_at = NOW()
      FROM duplicate_groups
      WHERE cmi.id = duplicate_groups.keeper_id;
    SQL

    execute <<~SQL
      WITH duplicate_groups AS (
        SELECT
          type,
          otu_id,
          geographic_item_id,
          project_id,
          MIN(id) AS keeper_id
        FROM cached_map_items
        GROUP BY type, otu_id, geographic_item_id, project_id
        HAVING COUNT(*) > 1
      )
      DELETE FROM cached_map_items cmi
      USING duplicate_groups
      WHERE
        cmi.id <> duplicate_groups.keeper_id
        AND cmi.type = duplicate_groups.type
        AND cmi.otu_id = duplicate_groups.otu_id
        AND cmi.geographic_item_id = duplicate_groups.geographic_item_id
        AND cmi.project_id IS NOT DISTINCT FROM duplicate_groups.project_id;
    SQL
  end
end
