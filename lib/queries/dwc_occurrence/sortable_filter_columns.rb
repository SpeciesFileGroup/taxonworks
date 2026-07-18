# `sortable_columns` for Queries::DwcOccurrence::Filter. Split out from
# filter.rb, same rationale as CollectionObject::SortableFilterColumns.
module Queries::DwcOccurrence::SortableFilterColumns
  extend ActiveSupport::Concern

  class_methods do
    def sortable_columns
      # rebuild_set is internal bookkeeping, not a DwC term; id/project_id/
      # created_by_id/updated_by_id are already excluded by the FK-column
      # guardrail.
      sortable_direct_columns.except('rebuild_set')
    end
  end
end
