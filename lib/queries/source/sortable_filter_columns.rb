# `sortable_columns` for Queries::Source::Filter. Split out from filter.rb,
# same rationale as CollectionObject::SortableFilterColumns.
module Queries::Source::SortableFilterColumns
  extend ActiveSupport::Concern

  class_methods do
    def sortable_columns_uncached
      cols = sortable_direct_columns

      # `belongs_to :serial` is only declared on Source::Bibtex, not the
      # base Source STI class this filter reflects on -- assoc() can't
      # walk it generically, so it stays hand-written.
      cols['serial'] = sort_by_belongs_to_column(
        joined_table: 'serials', joined_column: 'name',
        fk_expr: 'sources.serial_id',
        alias_prefix: 'sort_serial'
      )

      cols
    end
  end
end
