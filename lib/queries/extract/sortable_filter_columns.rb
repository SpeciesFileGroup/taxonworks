# `sortable_columns` for Queries::Extract::Filter. Split out from filter.rb,
# same rationale as CollectionObject::SortableFilterColumns.
module Queries::Extract::SortableFilterColumns
  extend ActiveSupport::Concern

  class_methods do
    # rubocop:disable Metrics/MethodLength
    def sortable_columns_uncached
      cols = sortable_direct_columns

      # `date` is the existing wire-format key for year_made.
      cols['date'] = direct(:year_made)

      # identifiers aggregate: MIN(cached) polymorphic on Extract.
      cols['identifiers'] = assoc(:identifiers, :cached, collapse: :aggregate)

      # Upstream (origin) OTUs. `related_origin_relationships` are
      # relationships where the extract is `new_object`, so origin OTUs
      # are `old_object` with `old_object_type = 'Otu'`. Filtering a
      # has_many to one polymorphic type isn't expressible via assoc(),
      # stays custom.
      cols['otus'] = ->(q, dir) {
        q.joins(<<~SQL.squish)
          LEFT JOIN LATERAL (
            SELECT MIN(COALESCE(tn.cached, o.name)) AS name
            FROM origin_relationships orl
            LEFT JOIN otus o ON o.id = orl.old_object_id
              AND orl.old_object_type = 'Otu'
            LEFT JOIN taxon_names tn ON tn.id = o.taxon_name_id
            WHERE orl.new_object_id = extracts.id
              AND orl.new_object_type = 'Extract'
          ) AS sort_ex_otus ON true
        SQL
        .order(Arel.sql("sort_ex_otus.name #{dir == :desc ? 'DESC' : 'ASC'} NULLS LAST"))
      }

      # Upstream origin types (Otu / CollectionObject / AnatomicalPart /
      # Extract). Sort by the alphabetically-first old_object_type.
      cols['originsType'] = ->(q, dir) {
        q.joins(<<~SQL.squish)
          LEFT JOIN LATERAL (
            SELECT MIN(old_object_type) AS type
            FROM origin_relationships
            WHERE new_object_id = extracts.id
              AND new_object_type = 'Extract'
          ) AS sort_ex_origin_type ON true
        SQL
        .order(Arel.sql("sort_ex_origin_type.type #{dir == :desc ? 'DESC' : 'ASC'} NULLS LAST"))
      }

      # Upstream origin labels (mirrors views/extracts/_attributes: uses
      # `label_for(old_object)`). Approximates label_for via CASE on
      # old_object_type -- Otu, CollectionObject, AnatomicalPart. Extract
      # (self-origin) has no cached label; falls through to NULL.
      cols['origins'] = ->(q, dir) {
        q.joins(<<~SQL.squish)
          LEFT JOIN LATERAL (
            SELECT MIN(
              CASE orl.old_object_type
              WHEN 'Otu' THEN (
                SELECT COALESCE(tn.cached, o.name)
                FROM otus o
                LEFT JOIN taxon_names tn ON tn.id = o.taxon_name_id
                WHERE o.id = orl.old_object_id
                LIMIT 1
              )
              WHEN 'CollectionObject' THEN (
                SELECT buffered_collecting_event
                FROM collection_objects
                WHERE id = orl.old_object_id
                LIMIT 1
              )
              WHEN 'AnatomicalPart' THEN (
                SELECT cached
                FROM anatomical_parts
                WHERE id = orl.old_object_id
                LIMIT 1
              )
              ELSE NULL
              END
            ) AS label
            FROM origin_relationships orl
            WHERE orl.new_object_id = extracts.id
              AND orl.new_object_type = 'Extract'
          ) AS sort_ex_origins ON true
        SQL
        .order(Arel.sql("sort_ex_origins.label #{dir == :desc ? 'DESC' : 'ASC'} NULLS LAST"))
      }

      cols
    end
    # rubocop:enable Metrics/MethodLength
  end
end
