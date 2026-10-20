# `sortable_columns` for Queries::FieldOccurrence::Filter. Split out from
# filter.rb, same rationale as CollectionObject::SortableFilterColumns
# (which this mirrors closely -- FieldOccurrence shares the
# collecting_event/dwc_occurrence/taxon_determination shape with
# CollectionObject via the same shared concerns).
module Queries::FieldOccurrence::SortableFilterColumns
  extend ActiveSupport::Concern

  class_methods do
    def sortable_columns_uncached
      cols = {}

      sortable_direct_columns.each { |c, lam| cols["field_occurrence.#{c}"] = lam }

      sortable_assoc_columns(:collecting_event).each { |c, lam| cols["collecting_event.#{c}"] = lam }

      cols['collecting_event.geographic_area_name'] = assoc(:collecting_event, :geographic_area, :name)

      sortable_assoc_columns(:dwc_occurrence).each { |c, lam| cols["dwc_occurrence.#{c}"] = lam }

      # taxon_determinations.* uses the primary (lowest-position) determination
      # for each FO (TaxonDetermination is acts_as_list, position 1 = primary).
      ::Queries::CollectionObject::SortableFilterColumns::SORTABLE_TAXON_DETERMINATION_COLUMNS.each do |c|
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
                WHERE taxon_determination_object_id = field_occurrences.id
                  AND taxon_determination_object_type = 'FieldOccurrence'
                ORDER BY position
                LIMIT 1
              ) AS #{lat} ON true
            SQL
            .order(Arel.sql("#{lat}.val #{dir == :desc ? 'DESC' : 'ASC'} NULLS LAST"))
          }
        end
      end

      cols['identifiers.cached'] = assoc(:identifiers, :cached, collapse: :aggregate)

      cols
    end
  end
end
