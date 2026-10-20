# `sortable_columns` for Queries::Source::Filter. Split out from filter.rb,
# same rationale as CollectionObject::SortableFilterColumns.
module Queries::Source::SortableFilterColumns
  extend ActiveSupport::Concern

  class_methods do
    def sortable_columns_uncached
      cols = sortable_direct_columns

      # `belongs_to :serial` is only declared on Source::Bibtex.
      cols['serial'] = assoc(:serial, :name, on: ::Source::Bibtex)

      cols
    end
  end
end
