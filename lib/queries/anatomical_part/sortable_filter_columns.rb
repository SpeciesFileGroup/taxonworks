# `sortable_columns` for Queries::AnatomicalPart::Filter. Split out from
# filter.rb, same rationale as CollectionObject::SortableFilterColumns.
module Queries::AnatomicalPart::SortableFilterColumns
  extend ActiveSupport::Concern

  class_methods do
    def sortable_columns_uncached
      sortable_direct_columns
    end
  end
end
