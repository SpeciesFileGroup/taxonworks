# Helpers for declaring sort keys (see Queries::Sort::Base) for cells that the filter
# tables assemble in Ruby (object tags, taxonomy) rather than read from a
# column. Rather than rebuilding that rendering in SQL, these sort on a
# simple value the cell visibly contains: the taxon of the row's OTU.
#
# The row's OTU, by object type:
# * Otu: itself
# * CollectionObject/FieldOccurrence: the OTU of its first determination
# * AnatomicalPart: its origin OTU
# Other types, and objects with no OTU, sort last.
#
# Each helper returns a lambda suitable as a `columns` value,
# `->(query, dir) { ... }`. Callers supply SQL expressions for the object's
# id and its (base class) type: a polymorphic _type column, or a quoted
# literal such as `'Otu'`.
#
# Each helper inlines its SQL via a LATERAL that always returns exactly one
# row (a SELECT with no FROM, or an aggregate), never `LIMIT 1`: Postgres can
# drop such a LATERAL from the pagination COUNT, never a LIMIT 1 one.
module Queries::Sort::ObjectOtu

  extend ActiveSupport::Concern

  class_methods do
    # The name at a rank in the classification of the valid name of the
    # object's OTU (the name itself or an ancestor).
    # @param rank [String] capitalized rank suffix matching the trailing
    #   segment of TaxonName#rank_class (e.g. 'Order', 'Family', 'Genus').
    # @param alias_prefix [String] unique-per-callsite alias so multiple
    #   sort keys can coexist in a single query.
    def sort_by_object_taxonomy(rank:, id_expr:, type_expr:, alias_prefix:)
      lat_alias = alias_prefix

      ->(q, dir) {
        q
          .joins(<<~SQL.squish)
            LEFT JOIN LATERAL (
              SELECT MIN(tn.name) AS name
              FROM otus o
              JOIN taxon_names n ON n.id = o.taxon_name_id
              JOIN taxon_name_hierarchies tnh ON tnh.descendant_id = n.cached_valid_taxon_name_id
              JOIN taxon_names tn
                ON tn.id = tnh.ancestor_id
                AND tn.rank_class LIKE '%::#{rank}'
              WHERE o.id = (#{object_otu_id_sql(id_expr:, type_expr:)})
            ) AS #{lat_alias} ON true
          SQL
          .order(Arel.sql("#{lat_alias}.name #{dir == :desc ? 'DESC' : 'ASC'} NULLS LAST"))
      }
    end

    # The name of the object's OTU: its taxon name, else its own name.
    # @param alias_prefix [String] unique-per-callsite alias.
    def sort_by_object_otu_name(id_expr:, type_expr:, alias_prefix:)
      lat_alias = alias_prefix

      ->(q, dir) {
        q
          .joins(<<~SQL.squish)
            LEFT JOIN LATERAL (
              SELECT (
                SELECT COALESCE(tn.cached, o.name)
                FROM otus o
                LEFT JOIN taxon_names tn ON tn.id = o.taxon_name_id
                WHERE o.id = (#{object_otu_id_sql(id_expr:, type_expr:)})
              ) AS name
            ) AS #{lat_alias} ON true
          SQL
          .order(Arel.sql("#{lat_alias}.name #{dir == :desc ? 'DESC' : 'ASC'} NULLS LAST"))
      }
    end

    private

    # See "The row's OTU" above.
    def object_otu_id_sql(id_expr:, type_expr:)
      determined = ->(object_type) {
        <<~SQL.squish
          SELECT td.otu_id
          FROM taxon_determinations td
          WHERE td.taxon_determination_object_id = (#{id_expr})
            AND td.taxon_determination_object_type = '#{object_type}'
          ORDER BY td.position, td.id
          LIMIT 1
        SQL
      }

      <<~SQL.squish
        CASE (#{type_expr})
        WHEN 'Otu' THEN (#{id_expr})
        WHEN 'CollectionObject' THEN (#{determined.('CollectionObject')})
        WHEN 'FieldOccurrence' THEN (#{determined.('FieldOccurrence')})
        WHEN 'AnatomicalPart' THEN (
          SELECT ap.cached_otu_id FROM anatomical_parts ap WHERE ap.id = (#{id_expr})
        )
        END
      SQL
    end
  end
end
