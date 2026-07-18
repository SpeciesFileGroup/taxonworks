# `sortable_columns` for Queries::Namespace::Filter. Split out from
# filter.rb, same rationale as CollectionObject::SortableFilterColumns.
module Queries::Namespace::SortableFilterColumns
  extend ActiveSupport::Concern

  class_methods do
    def sortable_columns
      cols = sortable_direct_columns

      # camelCase aliases matching the frontend's existing wire-format keys,
      # which don't match the underlying snake_case column names.
      cols['shortName'] = direct(:short_name)
      cols['verbatimShortName'] = direct(:verbatim_short_name)
      cols['isVirtual'] = direct(:is_virtual)

      cols
    end
  end
end
