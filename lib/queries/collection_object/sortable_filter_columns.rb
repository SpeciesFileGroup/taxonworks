# `sortable_columns` for Queries::CollectionObject::Filter. Split out from
# filter.rb because the column-group constants + declarations are sizable
# and largely orthogonal to the rest of the filter's facets.
#
# repository/current_repository/collecting_event/dwc_occurrence columns are
# no longer hand-enumerated: which of those columns are sortable is derived
# from the association's target table (minus blacklisted columns), since
# which of them are *displayed* is already a frontend decision (the UI
# already gates its sort buttons against whatever this reports as
# sortable) -- there's no separate reason to also hand-curate a list here.
module Queries::CollectionObject::SortableFilterColumns
  extend ActiveSupport::Concern

  SORTABLE_TAXON_DETERMINATION_COLUMNS = %w[
    otu_id otu_name position year_made month_made day_made print_label
  ].freeze

  class_methods do
    def sortable_columns
      cols = {}

      sortable_direct_columns.each { |c, lam| cols["collection_object.#{c}"] = lam }

      sortable_assoc_columns(:repository).each { |c, lam| cols["repository.#{c}"] = lam }
      sortable_assoc_columns(:current_repository).each { |c, lam| cols["current_repository.#{c}"] = lam }
      sortable_assoc_columns(:collecting_event).each { |c, lam| cols["collecting_event.#{c}"] = lam }

      # geographic_area_id is intentionally excluded from the auto-derived
      # collecting_event columns above (it's a raw foreign key); kept as its
      # own exception since it was already exposed and tested.
      cols['collecting_event.geographic_area_id'] = sort_by_belongs_to_column(
        joined_table: 'collecting_events', joined_column: 'geographic_area_id',
        fk_expr: 'collection_objects.collecting_event_id',
        alias_prefix: 'sort_ce_geographic_area_id'
      )

      sortable_assoc_columns(:dwc_occurrence).each { |c, lam| cols["dwc_occurrence.#{c}"] = lam }

      # taxon_determinations.* uses the primary (lowest-position) determination
      # for each CO (TaxonDetermination is acts_as_list, position 1 = primary).
      SORTABLE_TAXON_DETERMINATION_COLUMNS.each do |c|
        # `otu_name` is joined through otus; the rest are direct td columns,
        # still hand-written pending a similar migration pass.
        if c == 'otu_name'
          cols['taxon_determinations.otu_name'] = assoc(:taxon_determinations, :otu, :name, collapse: :position)
        else
          cols["taxon_determinations.#{c}"] = ->(q, dir) {
            lat = "sort_td_#{c}"
            q.joins(<<~SQL.squish)
              LEFT JOIN LATERAL (
                SELECT #{c} AS val
                FROM taxon_determinations
                WHERE taxon_determination_object_id = collection_objects.id
                  AND taxon_determination_object_type = 'CollectionObject'
                ORDER BY position
                LIMIT 1
              ) AS #{lat} ON true
            SQL
            .order(Arel.sql("#{lat}.val #{dir == :desc ? 'DESC' : 'ASC'} NULLS LAST"))
          }
        end
      end

      # identifiers.cached aggregates many identifiers per CO. Sort by the
      # alphabetically first identifier; rows with no identifier sort last.
      cols['identifiers.cached'] = assoc(:identifiers, :cached, collapse: :aggregate)

      cols
    end
  end
end
