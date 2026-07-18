# `sortable_columns` for Queries::BiologicalAssociation::Filter. Split out
# from filter.rb, same rationale as CollectionObject::SortableFilterColumns.
#
# Everything below id/updated_at/created_at is polymorphic type-dispatch or
# a closure-tree taxonomy walk (see sort_by_relationship_name,
# sort_by_taxonomy, sort_by_object_tag, sort_by_biological_property below in
# filter.rb) -- none of that is expressible via assoc(), so it stays
# hand-written.
module Queries::BiologicalAssociation::SortableFilterColumns
  extend ActiveSupport::Concern

  class_methods do
    def sortable_columns_uncached
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
  end
end
