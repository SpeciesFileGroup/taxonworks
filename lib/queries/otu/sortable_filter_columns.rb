# `sortable_columns` for Queries::Otu::Filter. Split out from filter.rb,
# same rationale as CollectionObject::SortableFilterColumns.
#
# `otu`/`otu_taxonomy_*` are a display-name COALESCE and closure-tree
# taxonomy walks (see sort_by_display_name in filter.rb and
# sort_by_object_taxonomy in Queries::Concerns::Sortable) -- neither is
# expressible via association(), so they stay hand-written.
module Queries::Otu::SortableFilterColumns
  extend ActiveSupport::Concern

  class_methods do
    def sortable_columns_uncached
      cols = sortable_direct_columns

      cols['otu'] = sort_by_display_name
      cols['otu_taxonomy_order'] = sort_by_object_taxonomy(
        rank: 'Order', id_expr: 'otus.id', type_expr: "'Otu'", alias_prefix: 'sort_otu_taxonomy_order'
      )
      cols['otu_taxonomy_family'] = sort_by_object_taxonomy(
        rank: 'Family', id_expr: 'otus.id', type_expr: "'Otu'", alias_prefix: 'sort_otu_taxonomy_family'
      )
      cols['otu_taxonomy_genus'] = sort_by_object_taxonomy(
        rank: 'Genus', id_expr: 'otus.id', type_expr: "'Otu'", alias_prefix: 'sort_otu_taxonomy_genus'
      )

      cols
    end
  end
end
