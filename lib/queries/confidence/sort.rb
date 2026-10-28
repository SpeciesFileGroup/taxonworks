# Sort keys for ::Confidence, see Queries::Sort::Base.
class Queries::Confidence::Sort < Queries::Sort::Base
  class << self
    def columns_uncached
      sortable_direct_columns.merge(
        'created_by'                  => association(:creator, :name),
        'confidence_level.object_tag' => association(:controlled_vocabulary_term, :name)
      )
    end
  end
end
