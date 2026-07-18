# `sortable_columns` for Queries::CollectingEvent::Filter. Split out from
# filter.rb, same rationale as CollectionObject::SortableFilterColumns.
module Queries::CollectingEvent::SortableFilterColumns
  extend ActiveSupport::Concern

  class_methods do
    # Frontend TableLayoutSelector emits column keys as
    # "<section>.<column>" (e.g. "collecting_event.verbatim_locality") when
    # CollectingEvent is embedded in another filter's table, and the bare
    # column name when it's the top-level filter -- register both forms for
    # every column so either usage's sort button works.
    def sortable_columns_uncached
      direct = sortable_direct_columns
      cols = {}
      direct.each do |c, lam|
        cols[c] = lam
        cols["collecting_event.#{c}"] = lam
      end
      cols
    end
  end
end
