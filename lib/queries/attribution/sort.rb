# Sort keys for ::Attribution, see Queries::Sort::Base.
class Queries::Attribution::Sort < Queries::Sort::Base
  class << self
    def columns_uncached
      sortable_direct_columns.merge(
        'created_by' => association(:creator, :name)
      )
    end
  end
end
