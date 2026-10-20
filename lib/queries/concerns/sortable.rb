# Helpers for declaring `sortable_columns` entries that need joins more
# complex than a single ORDER BY clause -- specifically the recurring
# patterns of (a) walking closure_tree to an ancestor at a given rank, and
# (b) dispatching on a polymorphic _type column to per-type display columns.
#
# Both helpers return a lambda suitable as a `sortable_columns` value,
# `->(query, dir) { ... }`. Callers supply the SQL fragments that identify
# the row-local OTU id (or polymorphic id/type) for their model.
#
# Each helper inlines its SQL via LATERAL so the per-row subquery returns
# at most one row -- this avoids the row multiplication you'd get from a
# plain LEFT JOIN through taxon_name_hierarchies.
module Queries::Concerns::Sortable

  extend ActiveSupport::Concern

  class_methods do
    # @param rank [String] capitalized rank suffix matching the trailing
    #   segment of TaxonName#rank_class (e.g. 'Order', 'Family', 'Genus').
    # @param otu_id_expr [String] SQL expression evaluating to an otu id for
    #   the outer row. May reference outer columns. Used inside the LATERAL.
    # @param alias_prefix [String] unique-per-callsite alias so multiple
    #   sort keys can coexist in a single query.
    def sort_by_otu_taxonomy(rank:, otu_id_expr:, alias_prefix:)
      rank_class_like = "%::#{rank}"
      lat_alias = alias_prefix

      ->(q, dir) {
        q
          .joins(<<~SQL.squish)
            LEFT JOIN LATERAL (
              SELECT tn.name AS name
              FROM otus o
              JOIN taxon_name_hierarchies tnh ON tnh.descendant_id = o.taxon_name_id
              JOIN taxon_names tn
                ON tn.id = tnh.ancestor_id
                AND tn.rank_class LIKE '#{rank_class_like}'
              WHERE o.id = (#{otu_id_expr})
              LIMIT 1
            ) AS #{lat_alias} ON true
          SQL
          .order(Arel.sql("#{lat_alias}.name #{dir == :desc ? 'DESC' : 'ASC'} NULLS LAST"))
      }
    end

    # @param id_expr [String] SQL expression evaluating to the polymorphic
    #   target id (e.g. `biological_associations.biological_association_object_id`).
    # @param type_expr [String] SQL expression evaluating to the polymorphic
    #   target type string (e.g. `biological_associations.biological_association_object_type`).
    # @param alias_prefix [String] unique-per-callsite alias.
    def sort_by_polymorphic_object_tag(id_expr:, type_expr:, alias_prefix:)
      lat_alias = alias_prefix

      ->(q, dir) {
        q
          .joins(<<~SQL.squish)
            LEFT JOIN LATERAL (
              SELECT CASE (#{type_expr})
                WHEN 'Otu' THEN (
                  SELECT COALESCE(tn.cached, o.name)
                  FROM otus o
                  LEFT JOIN taxon_names tn ON tn.id = o.taxon_name_id
                  WHERE o.id = (#{id_expr})
                  LIMIT 1
                )
                WHEN 'CollectionObject' THEN (
                  SELECT buffered_collecting_event
                  FROM collection_objects
                  WHERE id = (#{id_expr})
                  LIMIT 1
                )
                WHEN 'AnatomicalPart' THEN (
                  SELECT cached
                  FROM anatomical_parts
                  WHERE id = (#{id_expr})
                  LIMIT 1
                )
                ELSE NULL
              END AS tag
            ) AS #{lat_alias} ON true
          SQL
          .order(Arel.sql("#{lat_alias}.tag #{dir == :desc ? 'DESC' : 'ASC'} NULLS LAST"))
      }
    end
  end
end
