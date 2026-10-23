# Sort keys for ::Namespace, see Queries::Sort::Base.
class Queries::Namespace::Sort < Queries::Sort::Base
  class << self
    def columns_uncached
      cols = sortable_direct_columns

      # camelCase aliases matching the frontend's existing wire-format keys,
      # which don't match the underlying snake_case column names.
      cols['shortName'] = direct(:short_name)
      cols['verbatimShortName'] = direct(:verbatim_short_name)
      cols['isVirtual'] = direct(:is_virtual)

      cols
    end
  end
end
