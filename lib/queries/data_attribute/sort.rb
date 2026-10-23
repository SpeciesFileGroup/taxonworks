# Sort keys for ::DataAttribute, see Queries::Sort::Base.
class Queries::DataAttribute::Sort < Queries::Sort::Base
  class << self
    def columns_uncached
      sortable_direct_columns.merge(
        'created_by'                      => association(:creator, :name),
        'controlled_vocabulary_term.name' => association(:predicate, :name)
      )
    end
  end
end
