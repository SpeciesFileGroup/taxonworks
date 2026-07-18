# `sortable_columns` for Queries::Otu::Filter. Split out from filter.rb,
# same rationale as CollectionObject::SortableFilterColumns.
#
# `otu`/`otu_taxonomy_*` are a display-name COALESCE and closure-tree
# taxonomy walks (see sort_by_display_name/sort_by_otu_taxonomy below in
# filter.rb) -- neither is expressible via assoc(), so they stay
# hand-written.
module Queries::Otu::SortableFilterColumns
  extend ActiveSupport::Concern

  class_methods do
    def sortable_columns
      cols = sortable_direct_columns

      cols['otu'] = sort_by_display_name
      cols['otu_taxonomy_order'] = sort_by_otu_taxonomy(
        rank: 'Order', otu_id_expr: 'otus.id', alias_prefix: 'sort_otu_taxonomy_order'
      )
      cols['otu_taxonomy_family'] = sort_by_otu_taxonomy(
        rank: 'Family', otu_id_expr: 'otus.id', alias_prefix: 'sort_otu_taxonomy_family'
      )
      cols['otu_taxonomy_genus'] = sort_by_otu_taxonomy(
        rank: 'Genus', otu_id_expr: 'otus.id', alias_prefix: 'sort_otu_taxonomy_genus'
      )

      cols
    end
  end
end
