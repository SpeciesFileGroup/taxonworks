# Sort keys for ::Identifier, see Queries::Sort::Base.
class Queries::Identifier::Sort < Queries::Sort::Base
  class << self
    def columns_uncached
      sortable_direct_columns.merge(
        'created_by' => association(:creator, :name)
      )
    end
  end
end
