# Sort keys for ::Content, see Queries::Sort::Base.
class Queries::Content::Sort < Queries::Sort::Base
  class << self
    def columns_uncached
      cols = sortable_direct_columns

      # OTU shows the taxon_name.cached fallback to otu.name; a COALESCE
      # across a two-hop path isn't expressible via association(), stays custom.
      cols['otu'] = ->(q, dir) {
        order_by_sql(q, <<~SQL.squish, dir)
          (
            SELECT COALESCE(tn.cached, o.name)
            FROM otus o LEFT JOIN taxon_names tn ON tn.id = o.taxon_name_id
            WHERE o.id = contents.otu_id
          )
        SQL
      }

      cols['topic'] = association(:topic, :name)

      cols
    end
  end
end
