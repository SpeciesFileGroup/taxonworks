# Sort keys for ::BiologicalAssociation, see Queries::Sort::Base.
#
# Everything below id/updated_at/created_at is polymorphic type-dispatch or
# a closure-tree taxonomy walk (see sort_by_relationship_name,
# sort_by_taxonomy, sort_by_object_tag, sort_by_biological_property below)
# -- none of that is expressible via association(), so it stays hand-written.
class Queries::BiologicalAssociation::Sort < Queries::Sort::Base
  class << self
    def columns_uncached
      cols = sortable_direct_columns

      cols['biological_relationship'] = sort_by_relationship_name
      cols['subject_taxonomy_order'] = sort_by_taxonomy(side: 'subject', rank: 'Order')
      cols['subject_taxonomy_family'] = sort_by_taxonomy(side: 'subject', rank: 'Family')
      cols['subject_taxonomy_genus'] = sort_by_taxonomy(side: 'subject', rank: 'Genus')
      cols['object_taxonomy_order'] = sort_by_taxonomy(side: 'object', rank: 'Order')
      cols['object_taxonomy_family'] = sort_by_taxonomy(side: 'object', rank: 'Family')
      cols['object_taxonomy_genus'] = sort_by_taxonomy(side: 'object', rank: 'Genus')
      cols['subject_object_tag'] = sort_by_object_tag(side: 'subject')
      cols['object_object_tag'] = sort_by_object_tag(side: 'object')
      cols['biological_property_subject'] = sort_by_biological_property(side: 'subject')
      cols['biological_property_object'] = sort_by_biological_property(side: 'object')

      cols
    end

    def sort_by_relationship_name
      ->(q, dir) {
        order_by_sql(q.joins('LEFT JOIN biological_relationships AS sort_br ON sort_br.id = biological_associations.biological_relationship_id'), "sort_br.name", dir)
      }
    end

    # Sort by the name of the BiologicalProperty associated with this BA's
    # biological_relationship for the given side. If a relationship has multiple
    # properties on a side, picks the alphabetically first.
    def sort_by_biological_property(side:)
      brt_type = side == 'subject' ?
        'BiologicalRelationshipType::BiologicalRelationshipSubjectType' :
        'BiologicalRelationshipType::BiologicalRelationshipObjectType'
      lat_alias = "sort_prop_#{side}"

      ->(q, dir) {
        order_by_sql(q.joins(<<~SQL.squish), "#{lat_alias}.name", dir)
          LEFT JOIN LATERAL (
            SELECT MIN(cvt.name) AS name
            FROM biological_relationship_types brt
            JOIN controlled_vocabulary_terms cvt ON cvt.id = brt.biological_property_id
            WHERE brt.biological_relationship_id = biological_associations.biological_relationship_id
              AND brt.type = '#{brt_type}'
          ) AS #{lat_alias} ON true
        SQL
      }
    end

    # The subject's/object's tag is rendered in Ruby; sort on the taxon it
    # shows (see Queries::Sort::ObjectOtu).
    def sort_by_object_tag(side:)
      sort_by_object_otu_name(
        id_expr:   "biological_associations.biological_association_#{side}_id",
        type_expr: "biological_associations.biological_association_#{side}_type",
        alias_prefix: "sort_objtag_#{side}"
      )
    end

    # The subject's/object's taxonomy at the given rank, from its OTU (see
    # Queries::Sort::ObjectOtu).
    def sort_by_taxonomy(side:, rank:)
      sort_by_object_taxonomy(
        rank: rank,
        id_expr: "biological_associations.biological_association_#{side}_id",
        type_expr: "biological_associations.biological_association_#{side}_type",
        alias_prefix: "sort_tax_#{side}_#{rank.downcase}"
      )
    end
  end
end
