module Queries::AnatomicalPart::SortableFilterColumns
  extend ActiveSupport::Concern

  class_methods do
    def sortable_columns_uncached
      sortable_direct_columns
    end
  end
end
