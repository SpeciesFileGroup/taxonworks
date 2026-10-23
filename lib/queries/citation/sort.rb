# Sort keys for ::Citation, see Queries::Sort::Base.
class Queries::Citation::Sort < Queries::Sort::Base
  class << self
    def columns_uncached
      sortable_direct_columns.merge(
        'created_by'    => association(:creator, :name),
        'source.cached' => association(:source, :cached)
      )
    end
  end
end
