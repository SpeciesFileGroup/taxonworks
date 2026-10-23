# Sort keys for ::CollectionObject, see Queries::Sort::Base.
#
# repository/current_repository/collecting_event/dwc_occurrence columns are
# no longer hand-enumerated: which of those columns are sortable is derived
# from the association's target table (minus blacklisted columns), since
# which of them are *displayed* is already a frontend decision (the UI
# already gates its sort buttons against whatever this reports as
# sortable) -- there's no separate reason to also hand-curate a list here.
class Queries::CollectionObject::Sort < Queries::Sort::Base
  SORTABLE_TAXON_DETERMINATION_COLUMNS = %w[
    otu_id otu_name position year_made month_made day_made print_label
  ].freeze

  class << self
    def columns_uncached
      cols = {}

      sortable_direct_columns.each { |c, lam| cols["collection_object.#{c}"] = lam }

      sortable_association_columns(:repository).each { |c, lam| cols["repository.#{c}"] = lam }
      sortable_association_columns(:current_repository).each { |c, lam| cols["current_repository.#{c}"] = lam }
      sortable_association_columns(:collecting_event).each { |c, lam| cols["collecting_event.#{c}"] = lam }

      cols['collecting_event.geographic_area_name'] = association(:collecting_event, :geographic_area, :name)

      sortable_association_columns(:dwc_occurrence).each { |c, lam| cols["dwc_occurrence.#{c}"] = lam }

      # taxon_determinations.* uses the primary (lowest-position) determination
      # for each CO (TaxonDetermination is acts_as_list, position 1 = primary).
      # otu_id goes through the otu's id: the resolver refuses raw foreign keys.
      SORTABLE_TAXON_DETERMINATION_COLUMNS.each do |c|
        cols["taxon_determinations.#{c}"] =
          case c
          when 'otu_id' then association(:taxon_determinations, :otu, :id, collapse: :position)
          when 'otu_name' then association(:taxon_determinations, :otu, :name, collapse: :position)
          else association(:taxon_determinations, c, collapse: :position)
          end
      end

      # Sort by the identifiers as the table shows them: in position order,
      # joined; rows with no identifier sort last.
      cols['identifiers.cached'] = association(:identifiers, :cached, collapse: :joined)

      cols
    end
  end
end
