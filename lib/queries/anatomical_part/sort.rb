# Sort keys for ::AnatomicalPart, see Queries::Sort::Base.
class Queries::AnatomicalPart::Sort < Queries::Sort::Base
  class << self
    def columns_uncached
      sortable_direct_columns
    end
  end
end
