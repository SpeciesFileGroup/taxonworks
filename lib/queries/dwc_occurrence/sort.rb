# Sort keys for ::DwcOccurrence, see Queries::Sort::Base.
class Queries::DwcOccurrence::Sort < Queries::Sort::Base
  class << self
    def columns_uncached
      # rebuild_set is internal bookkeeping, not a DwC term; id/project_id/
      # created_by_id/updated_by_id are already excluded by the FK-column
      # guardrail.
      sortable_direct_columns.except('rebuild_set')
    end
  end
end
