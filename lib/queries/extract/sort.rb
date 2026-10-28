# Sort keys for ::Extract, see Queries::Sort::Base.
class Queries::Extract::Sort < Queries::Sort::Base
  class << self
    # rubocop:disable Metrics/MethodLength
    def columns_uncached
      cols = sortable_direct_columns

      # `date` is the existing wire-format key for year_made.
      cols['date'] = direct(:year_made)

      # Sort by the identifiers as the table shows them: in position order, joined.
      cols['identifiers'] = association(:identifiers, :cached, collapse: :joined)

      # Upstream (origin) OTUs. `related_origin_relationships` are
      # relationships where the extract is `new_object`, so origin OTUs
      # are `old_object` with `old_object_type = 'Otu'`. Filtering a
      # has_many to one polymorphic type isn't expressible via association(),
      # stays custom.
      cols['otus'] = ->(q, dir) {
        order_by_sql(q.joins(<<~SQL.squish), "sort_ex_otus.name", dir)
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
      }

      # Upstream origin types (Otu / CollectionObject / AnatomicalPart /
      # Extract). Sort by the alphabetically-first old_object_type.
      cols['originsType'] = ->(q, dir) {
        order_by_sql(q.joins(<<~SQL.squish), "sort_ex_origin_type.type", dir)
          LEFT JOIN LATERAL (
            SELECT MIN(old_object_type) AS type
            FROM origin_relationships
            WHERE new_object_id = extracts.id
              AND new_object_type = 'Extract'
          ) AS sort_ex_origin_type ON true
        SQL
      }

      # No `origins` sort: the column is a list of labels rendered in Ruby
      # (label_for each origin object), with no simple value to sort on.

      cols
    end
    # rubocop:enable Metrics/MethodLength
  end
end
