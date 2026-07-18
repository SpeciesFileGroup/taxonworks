# `sortable_columns` for Queries::TaxonNameRelationship::Filter. Split out
# from filter.rb, same rationale as CollectionObject::SortableFilterColumns.
module Queries::TaxonNameRelationship::SortableFilterColumns
  extend ActiveSupport::Concern

  class_methods do
    def sortable_columns_uncached
      cols = sortable_direct_columns

      # `relationship` is the existing wire-format key for the STI `type`
      # column (auto-derived separately as 'type'); kept as an explicit
      # alias for backward compatibility.
      cols['relationship'] = direct(:type)

      cols['subject'] = assoc(:subject_taxon_name, :cached)
      cols['object'] = assoc(:object_taxon_name, :cached)

      cols
    end
  end
end
