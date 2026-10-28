# Sort keys for ::Documentation, see Queries::Sort::Base.
class Queries::Documentation::Sort < Queries::Sort::Base
  class << self
    def columns_uncached
      sortable_direct_columns.merge(
        'created_by'          => association(:creator, :name),
        'document.object_tag' => association(:document, :document_file_file_name)
      )
    end
  end
end
