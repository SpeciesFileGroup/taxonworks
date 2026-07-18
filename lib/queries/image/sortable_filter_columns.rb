# `sortable_columns` for Queries::Image::Filter. Split out from filter.rb,
# same rationale as CollectionObject::SortableFilterColumns.
module Queries::Image::SortableFilterColumns
  extend ActiveSupport::Concern

  class_methods do
    def sortable_columns
      sortable_direct_columns
    end
  end
end
