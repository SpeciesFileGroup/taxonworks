# Sort keys for ::Tag, see Queries::Sort::Base.
class Queries::Tag::Sort < Queries::Sort::Base
  class << self
    def columns_uncached
      sortable_direct_columns.merge(
        'created_by'         => association(:creator, :name),
        'keyword.object_tag' => association(:controlled_vocabulary_term, :name)
      )
    end
  end
end
