# `sortable_columns` for Queries::AssertedDistribution::Filter. Split out
# from filter.rb, same rationale as CollectionObject::SortableFilterColumns.
#
# asserted_distribution_shape/data_origin/object_object_tag/citations all
# involve polymorphic type-dispatch (or an aggregate combined with a further
# hop) that isn't expressible via assoc()/collapse: :aggregate, so they stay
# hand-written.
module Queries::AssertedDistribution::SortableFilterColumns
  extend ActiveSupport::Concern

  class_methods do
    # rubocop:disable Metrics/MethodLength
    def sortable_columns
      cols = sortable_direct_columns

      # Existing wire-format key for the polymorphic object type column.
      cols['object_type'] = direct(:asserted_distribution_object_type)

      # asserted_distribution_shape is polymorphic (GeographicArea or Gazetteer);
      # both tables have a `name` column, so we can COALESCE across them.
      cols['asserted_distribution_shape'] = ->(q, dir) {
        q.joins(<<~SQL.squish)
          LEFT JOIN LATERAL (
            SELECT CASE asserted_distributions.asserted_distribution_shape_type
              WHEN 'GeographicArea' THEN (
                SELECT name FROM geographic_areas
                WHERE id = asserted_distributions.asserted_distribution_shape_id
                LIMIT 1
              )
              WHEN 'Gazetteer' THEN (
                SELECT name FROM gazetteers
                WHERE id = asserted_distributions.asserted_distribution_shape_id
                LIMIT 1
              )
              ELSE NULL
            END AS name
          ) AS sort_ad_shape ON true
        SQL
        .order(Arel.sql("sort_ad_shape.name #{dir == :desc ? 'DESC' : 'ASC'} NULLS LAST"))
      }

      # data_origin only exists on GeographicArea shapes; Gazetteer rows sort NULL.
      cols['data_origin'] = ->(q, dir) {
        q.joins(<<~SQL.squish)
          LEFT JOIN LATERAL (
            SELECT data_origin FROM geographic_areas
            WHERE asserted_distributions.asserted_distribution_shape_type = 'GeographicArea'
              AND geographic_areas.id = asserted_distributions.asserted_distribution_shape_id
            LIMIT 1
          ) AS sort_ad_origin ON true
        SQL
        .order(Arel.sql("sort_ad_origin.data_origin #{dir == :desc ? 'DESC' : 'ASC'} NULLS LAST"))
      }

      # Polymorphic object: typically Otu; also could be TaxonName.
      # Otu.object_tag ≈ COALESCE(taxon_names.cached, otus.name).
      # TaxonName.object_tag ≈ taxon_names.cached.
      cols['object_object_tag'] = ->(q, dir) {
        q.joins(<<~SQL.squish)
          LEFT JOIN LATERAL (
            SELECT CASE asserted_distributions.asserted_distribution_object_type
              WHEN 'Otu' THEN (
                SELECT COALESCE(tn.cached, o.name)
                FROM otus o
                LEFT JOIN taxon_names tn ON tn.id = o.taxon_name_id
                WHERE o.id = asserted_distributions.asserted_distribution_object_id
                LIMIT 1
              )
              WHEN 'TaxonName' THEN (
                SELECT cached FROM taxon_names
                WHERE id = asserted_distributions.asserted_distribution_object_id
                LIMIT 1
              )
              ELSE NULL
            END AS tag
          ) AS sort_ad_object ON true
        SQL
        .order(Arel.sql("sort_ad_object.tag #{dir == :desc ? 'DESC' : 'ASC'} NULLS LAST"))
      }

      # Citations aggregate: sort by alphabetically first citation's
      # source cached string.
      cols['citations'] = ->(q, dir) {
        q.joins(<<~SQL.squish)
          LEFT JOIN LATERAL (
            SELECT MIN(sources.cached) AS cached
            FROM citations
            JOIN sources ON sources.id = citations.source_id
            WHERE citations.citation_object_id = asserted_distributions.id
              AND citations.citation_object_type = 'AssertedDistribution'
          ) AS sort_ad_citations ON true
        SQL
        .order(Arel.sql("sort_ad_citations.cached #{dir == :desc ? 'DESC' : 'ASC'} NULLS LAST"))
      }

      cols
    end
    # rubocop:enable Metrics/MethodLength
  end
end
