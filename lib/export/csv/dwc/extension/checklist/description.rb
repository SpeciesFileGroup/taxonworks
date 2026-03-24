# CSV for Description extension (for checklist archives).
# See http://rs.gbif.org/extension/gbif/1.0/description.xml
#
# Exports Content records (OTU text descriptions by topic) as html.
module Export::CSV::Dwc::Extension::Checklist::Description

  GBIF = Export::Dwca::GbifProfile::SpeciesDescription

  # Fields used in checklist exports (subset of full GBIF profile).
  CHECKLIST_FIELDS = [
    :id, # Required for DwC-A star joins (taxonID, an OTU UUID)
    GBIF::DESCRIPTION,
    GBIF::TYPE,
    GBIF::LANGUAGE,
    GBIF::CREATED
  ].freeze

  HEADERS = CHECKLIST_FIELDS

  HEADERS_NAMESPACES = CHECKLIST_FIELDS.map do |field|
    field == :id ? '' : GBIF::NAMESPACES[field]
  end.freeze

  # Generate CSV for description extension from Content records.
  # @param core_otu_scope [Hash] OTU query params from Checklist::Data
  # @param taxon_name_id_to_taxon_id [Hash] taxon_name_id => OTU UUID (used as dwc:taxonID in the checklist core)
  # @param description_topics [Array<Integer>] ordered array of topic IDs to include
  # @return [String] CSV content
  def self.csv(core_otu_scope, taxon_name_id_to_taxon_id, description_topics: [])
    tbl = []
    tbl[0] = HEADERS

    return ::Export::Dwca.output_csv(tbl) if description_topics.empty?

    otu_scope = ::Queries::Otu::Filter.new(core_otu_scope).all

    # Only include published (public) contents
    contents = Content
      .joins(:otu)
      .merge(otu_scope)
      .where(topic_id: description_topics)
      .joins(:public_content)
      .includes(:language, :topic, otu: :taxon_name)

    # Sort by topic order as specified by user
    topic_order = description_topics.each_with_index.to_h
    contents = contents.sort_by { |c| topic_order[c.topic_id] || Float::INFINITY }

    contents.each do |content|
      taxon_name = content.otu.taxon_name
      taxon_name_id = taxon_name.cached_valid_taxon_name_id || taxon_name.id
      taxon_id = taxon_name_id_to_taxon_id[taxon_name_id]
      next unless taxon_id

      html_description = if content.text.present?
        content.to_html
      else
        nil
      end

      # Format created date from updated_at
      created_date = content.updated_at.strftime('%Y-%m-%d')

      row = [
        taxon_id,
        html_description,
        content.topic.name,
        content.language&.alpha_2,
        created_date
      ]

      tbl << row
    end

    ::Export::Dwca.output_csv(tbl)
  end

end
