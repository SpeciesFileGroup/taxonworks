# `sortable_columns` for Queries::Person::Filter. Split out from filter.rb,
# same rationale as CollectionObject::SortableFilterColumns.
module Queries::Person::SortableFilterColumns
  extend ActiveSupport::Concern

  class_methods do
    def sortable_columns
      sortable_direct_columns
    end
  end
end
