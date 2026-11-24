# Citation support for the DwC occurrence importer (Claude-generated: majority of this module).
#
# Columns follow the TW native header style, `TW:<Model>:<attribute>`, e.g. `TW:TaxonName:source_id`.
# When a row supplies a `source_id` for a model, a Citation to that Source is added to the
# corresponding record created (or matched) by the import.
#
# Supported models: see CITATION_MODELS
# Supported attributes: see CITATION_ATTRIBUTES
#   * source_id - required for the other two, must be an integer id of an existing Source
#   * source_pages - Citation#pages
#   * source_is_original - Citation#is_original; "true"/"1", "false"/"0", or blank
#
# Application rules:
#   * TaxonName - only the finest name, and only when it is created by this row; a pre-existing name errors the row
#   * Otu - the Otu used for the TaxonDetermination
#   * CollectingEvent, Otu - may be pre-existing/shared; identical Citations are matched, not duplicated
#   * CollectionObject - ignored for HumanObservation records (as all other TW:CollectionObject columns are)
#   * FieldOccurrence - only for HumanObservation records, ignored otherwise (as all other TW:FieldOccurrence columns are)
#   * TypeMaterial - requires typeStatus; skipped when TypeMaterial creation fails in best-effort mode
#
module DatasetRecord::DarwinCore::Occurrence::CitationColumns
  extend ActiveSupport::Concern

  CITATION_MODELS = %w{Otu TaxonName CollectionObject FieldOccurrence CollectingEvent TypeMaterial}.freeze

  CITATION_ATTRIBUTES = %w{source_id source_pages source_is_original}.freeze

  CITATION_FIELD_REGEX = /\ATW:(#{CITATION_MODELS.join('|')}):(#{CITATION_ATTRIBUTES.join('|')})\z/i

  class_methods do
    # @param headers [Array<String>]
    # @return [Hash{String => Hash{String => Integer}}]
    #   e.g. { 'TaxonName' => { 'source_id' => 3, 'source_pages' => 4 } }
    def citation_columns(headers)
      (headers || []).each_with_index.each_with_object({}) do |(header, index), columns|
        next unless (match = CITATION_FIELD_REGEX.match(header.to_s.strip))

        model = CITATION_MODELS.detect { |m| m.casecmp?(match[1]) }
        (columns[model] ||= {})[match[2].downcase] = index
      end
    end

    # @param values [Array<String>] raw `source_id` cell values
    # @return [Hash{String => Source, String}]
    #   each (whitespace normalized) value mapped to its Source, or to an error message
    def resolve_citation_sources(values)
      values = values.compact.map { |v| v.gsub(/^[[:space:]]+|[[:space:]]+$/, '') }.reject(&:blank?).uniq
      ids = values.select { |v| v.match?(/\A\d+\z/) }.map(&:to_i)
      sources = Source.where(id: ids).index_by(&:id)

      values.to_h do |v|
        result = if !v.match?(/\A\d+\z/)
          "'#{v}' is not a valid integer value"
        else
          sources[v.to_i] || "Source with id #{v} not found"
        end
        [v, result]
      end
    end
  end

  def citation_columns
    import_dataset.citation_columns
  end

  # @return [Array<Integer>] column indexes of all citation fields
  def citation_field_indexes
    citation_columns.values.flat_map(&:values)
  end

  def citation_field?(attribute_name)
    CITATION_ATTRIBUTES.include?(attribute_name.to_s)
  end

  private

  # Validates citation columns for this row and resolves Sources. Call before creating any data
  # so that bad rows fail fast.
  # @return [Hash{String => Hash}] model => { source:, pages:, is_original: }, only for models with a source_id
  def parse_citations
    citation_columns.keys.each_with_object({}) do |model, citations|
      next if model == ignored_occurrence_model

      source_field, pages_field, is_original_field = CITATION_ATTRIBUTES.map { |a| "TW:#{model}:#{a}" }

      source_value = get_field_value(source_field)
      pages = get_field_value(pages_field)
      is_original = parse_citation_is_original(is_original_field)

      if source_value.nil?
        { pages_field => pages, is_original_field => is_original }.each do |field, value|
          raise DatasetRecord::DarwinCore::InvalidData.new({ field => ["requires a value in #{source_field}"] }) unless value.nil?
        end
        next
      end

      source = import_dataset.citation_source(source_value)
      raise DatasetRecord::DarwinCore::InvalidData.new({ source_field => [source] }) if source.is_a?(String)

      if model == 'TypeMaterial' && get_field_value(:typeStatus).nil?
        raise DatasetRecord::DarwinCore::InvalidData.new({ source_field => ['requires typeStatus, no TypeMaterial is created for this record'] })
      end

      citations[model] = { source:, pages:, is_original: }
    end
  end

  # @return [String] the occurrence model whose citation columns do not apply to this row
  def ignored_occurrence_model
    human_observation? ? 'CollectionObject' : 'FieldOccurrence'
  end

  # @return [Boolean, nil]
  def parse_citation_is_original(field)
    value = get_field_value(field)
    return nil if value.nil?
    return true if value.casecmp?('true') || value == '1'
    return false if value.casecmp?('false') || value == '0'

    raise DatasetRecord::DarwinCore::InvalidData.new({ field => ['must be "true" or "1", or blank, "false", or "0"'] })
  end

  # Cite citation_object if the row supplied a Source for model. An identical existing Citation
  # (same object, source, and pages) is re-used.
  # @param citations [Hash] as returned by #parse_citations
  def add_citation(citations, model, citation_object)
    return unless (attributes = citations[model]) && citation_object

    citation = Citation.find_or_initialize_by(citation_object:, source: attributes[:source], pages: attributes[:pages])
    citation.is_original = attributes[:is_original] unless attributes[:is_original].nil?
    citation.annotator_batch_mode = true

    citation.save! if citation.new_record? || citation.changed?
  rescue ActiveRecord::RecordInvalid => e
    raise DatasetRecord::DarwinCore::InvalidData.new({ "TW:#{model}:source_id" => e.record.errors.full_messages })
  end

  # @raise DatasetRecord::DarwinCore::InvalidData if a TaxonName citation is requested but the
  #   finest name was not created by this row
  def check_taxon_name_citation!(citations, taxon_name)
    return unless citations.key?('TaxonName')
    return if taxon_name&.previously_new_record?

    name = taxon_name ? "TaxonName '#{taxon_name.cached.presence || taxon_name.name}' [id: #{taxon_name.id}]" : 'The TaxonName'

    raise DatasetRecord::DarwinCore::InvalidData.new({
      'TW:TaxonName:source_id' => ["#{name} already exists. Citations are only added to the finest TaxonName when it is created by the import."]
    })
  end
end
