# CSV for Description extension (for checklist archives).
# See http://rs.gbif.org/extension/gbif/1.0/description.xml
#
# Note: Exports Content records (OTU text descriptions by topic).
# Converts markdown to HTML using Redcarpet.
module Export::CSV::Dwc::Extension::Checklist::Description

  GBIF = Export::Dwca::GbifProfile::SpeciesDescription

  # Fields used in checklist exports (subset of full GBIF profile).
  CHECKLIST_FIELDS = [
    :id, # Required for DwC-A star joins (maps to taxonID)
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
  # @param taxon_name_id_to_taxon_id [Hash] mapping of taxon_name_id => taxonID
  # @param description_topics [Array<Integer>] ordered array of topic IDs to include
  # @return [String] CSV content
  def self.csv(core_otu_scope, taxon_name_id_to_taxon_id, description_topics: [])
    tbl = []
    tbl[0] = HEADERS

    return output_csv(tbl) if description_topics.empty?

    otus = ::Queries::Otu::Filter.new(core_otu_scope).all

    # Only include published (public) contents
    contents = Content
      .where(otu_id: otus.select(:id))
      .where(topic_id: description_topics)
      .joins(:public_content)
      .includes(:language, :topic, otu: :taxon_name)

    # Sort by topic order as specified by user
    topic_order = description_topics.each_with_index.to_h
    contents = contents.sort_by { |c| topic_order[c.topic_id] || Float::INFINITY }

    # Initialize markdown renderer
    renderer = Redcarpet::Render::HTML.new
    markdown = Redcarpet::Markdown.new(renderer)

    contents.each do |content|
      taxon_name = content.otu&.taxon_name
      next unless taxon_name

      # Map to valid taxon (contents are associated with OTUs, which link to taxa)
      taxon_name_id = taxon_name.cached_valid_taxon_name_id || taxon_name.id
      taxon_id = taxon_name_id_to_taxon_id[taxon_name_id]
      next unless taxon_id

      # Convert markdown to HTML, removing trailing newline and converting internal newlines to <br>
      html_description = if content.text.present?
        markdown.render(content.text).chomp.gsub(/\n/, '<br>')
      else
        nil
      end

      # Format created date from updated_at
      created_date = content.updated_at&.strftime('%Y-%m-%d')

      row = [
        taxon_id,
        html_description,
        content.topic&.name,
        content.language&.alpha_2,
        created_date
      ]

      tbl << row
    end

    output_csv(tbl)
  end

  # Helper to output CSV from table array
  # @param tbl [Array<Array>] table data
  # @return [String] CSV content
  def self.output_csv(tbl)
    output = StringIO.new
    tbl.each do |row|
      output.puts ::CSV.generate_line(row, col_sep: "\t", encoding: Encoding::UTF_8)
    end
    output.string
  end

end
