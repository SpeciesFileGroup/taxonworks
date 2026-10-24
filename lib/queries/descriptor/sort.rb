# Sort keys for ::Descriptor, see Queries::Sort::Base.
class Queries::Descriptor::Sort < Queries::Sort::Base
  class << self
    def columns_uncached
      cols = sortable_direct_columns

      # character_states is a has_many count, not a value pulled from a
      # single row -- collapse: :aggregate only supports MIN, so this stays
      # hand-written.
      cols['character_states'] = ->(q, dir) {
        order_by_sql(q.joins(<<~SQL.squish), "sort_desc_cs.n", dir)
          LEFT JOIN LATERAL (
            SELECT COUNT(*) AS n
            FROM character_states
            WHERE character_states.descriptor_id = descriptors.id
          ) AS sort_desc_cs ON true
        SQL
      }

      cols
    end
  end
end
