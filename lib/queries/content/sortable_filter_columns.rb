# `sortable_columns` for Queries::Content::Filter. Split out from filter.rb,
# same rationale as CollectionObject::SortableFilterColumns.
module Queries::Content::SortableFilterColumns
  extend ActiveSupport::Concern

  class_methods do
    def sortable_columns_uncached
      cols = sortable_direct_columns

      # OTU shows the taxon_name.cached fallback to otu.name; a COALESCE
      # across a two-hop path isn't expressible via association(), stays custom.
      cols['otu'] = ->(q, dir) {
        q.order(Arel.sql(<<~SQL.squish))
          (
            SELECT COALESCE(tn.cached, o.name)
            FROM otus o LEFT JOIN taxon_names tn ON tn.id = o.taxon_name_id
            WHERE o.id = contents.otu_id
          ) #{dir == :desc ? 'DESC' : 'ASC'} NULLS LAST
        SQL
      }

      cols['topic'] = association(:topic, :name)

      cols
    end
  end
end
