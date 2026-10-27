# Sort keys for ::AssertedEnvironment, see Queries::Sort::Base.
class Queries::AssertedEnvironment::Sort < Queries::Sort::Base
  class << self
    def columns_uncached
      sortable_direct_columns.merge(
        # The filter table's "Object type" column.
        'object_type' => direct(:asserted_environment_object_type)
      )
    end
  end
end
