# Sort keys for ::Person, see Queries::Sort::Base.
class Queries::Person::Sort < Queries::Sort::Base
  class << self
    def columns_uncached
      sortable_direct_columns
    end
  end
end
