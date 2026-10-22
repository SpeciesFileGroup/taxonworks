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
      # otu_id goes through the otu's id: the resolver refuses raw foreign keys.
      ::Queries::CollectionObject::SortableFilterColumns::SORTABLE_TAXON_DETERMINATION_COLUMNS.each do |c|
        cols["taxon_determinations.#{c}"] =
          case c
          when 'otu_id' then assoc(:taxon_determinations, :otu, :id, collapse: :position)
          when 'otu_name' then assoc(:taxon_determinations, :otu, :name, collapse: :position)
          else assoc(:taxon_determinations, c, collapse: :position)
          end
      end

      cols['identifiers.cached'] = assoc(:identifiers, :cached, collapse: :aggregate)

      cols
    end
  end
end
