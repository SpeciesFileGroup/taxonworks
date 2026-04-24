# CSV for Species Distribution extension (for checklist archives)
# See http://rs.gbif.org/extension/gbif/1.0/distribution.xml
#
module Export::CSV::Dwc::Extension::Checklist::SpeciesDistribution

  GBIF = Export::Dwca::GbifProfile::SpeciesDistribution

  # Fields used in checklist exports (subset of full GBIF profile).
  CHECKLIST_FIELDS = [
    :id, # Required for DwC-A star joins (taxonID, an OTU UUID)
    :locality,
    :occurrenceStatus,
    :source
  ].freeze

  HEADERS = CHECKLIST_FIELDS

  HEADERS_NAMESPACES = CHECKLIST_FIELDS.map do |field|
    field == :id ? '' : GBIF::NAMESPACES[field]
  end.freeze

  # Generate CSV for species distribution extension.
  # @param scope [ActiveRecord::Relation] DwcOccurrence records from
  #   AssertedDistribution
  # @param taxon_name_id_to_taxon_id [Hash] taxon_name_id => OTU UUID (used as dwc:taxonID in the checklist core)
  # @param accepted_name_mode [String] checklist synonym handling mode
  # @return [String] CSV content
  def self.csv(scope, taxon_name_id_to_taxon_id, accepted_name_mode:)
    tbl = []
    tbl[0] = HEADERS
    grouped_rows = {}

    otu_to_taxon_name_id = scope
      .joins('JOIN otus ON otus.id = dwc_occurrences.otu_id')
      .joins('JOIN taxon_names ON taxon_names.id = otus.taxon_name_id')
      .pluck(
        Arel.sql('dwc_occurrences.otu_id'),
        Arel.sql(
          if accepted_name_mode == ::Export::Dwca::Checklist::Data::ACCEPTED_NAME_USAGE_ID
            'taxon_names.id'
          else
            'COALESCE(taxon_names.cached_valid_taxon_name_id, taxon_names.id)'
          end
        )
      )
      .to_h

    scope.find_each do |dwc_occ|
      # Use locality field if populated (for regional areas like "West Tropical Africa"),
      # otherwise build from country/state/county.
      locality = dwc_occ.locality.presence || begin
        locality_parts = [
          dwc_occ.country,
          dwc_occ.stateProvince,
          dwc_occ.county
        ].compact.reject(&:empty?)
        locality_parts.join(', ').presence
      end

      taxon_name_id = otu_to_taxon_name_id[dwc_occ.otu_id]
      next unless taxon_name_id

      taxon_id = taxon_name_id_to_taxon_id[taxon_name_id]
      next unless taxon_id

      key = [taxon_id, locality, dwc_occ.occurrenceStatus]
      source_parts = split_sources(dwc_occ.associatedReferences)

      grouped_rows[key] ||= []
      source_parts.each do |source|
        grouped_rows[key] << source unless grouped_rows[key].include?(source)
      end
    end

    grouped_rows.each do |(taxon_id, locality, occurrence_status), sources|
      tbl << [
        taxon_id,
        locality,
        occurrence_status,
        join_sources(sources)
      ]
    end

    ::Export::Dwca.output_csv(tbl)
  end

  def self.split_sources(source_string)
    return [] if source_string.blank?

    source_string.split(' | ').map(&:strip).reject(&:blank?)
  end

  def self.join_sources(sources)
    return nil if sources.blank?

    sources.join(' | ')
  end

end
