require 'csv'

module Export::Dwca::Occurrence
  # Service object for exporting TaxonWorks custom fields to DwCA.
  class TaxonworksExtensionExporter
    # @param core_scope [ActiveRecord::Relation] DwcOccurrence scope
    # @param taxonworks_extension_methods [Array<String, Symbol>] extension field names
    def initialize(core_scope:, taxonworks_extension_methods: [])
      @core_scope = core_scope
      @taxonworks_extension_methods = taxonworks_extension_methods
    end

    # Main export method - writes TaxonWorks extension data to output file.
    # @param output_file [Tempfile, File] output file for extension TSV data
    # @return [Tempfile] the output file
    def export_to(output_file)
      data = extension_data_query_data
      query = data[:query]
      column_data = data[:column_data]
      used_extensions = data[:used_extensions]

      if used_extensions.empty? || !collection_object_scope.exists?
        Rails.logger.debug 'dwca_export: taxonworks_extension_data prepared - ' + (used_extensions.empty? ? 'no extensions' : 'no collection objects')
        return output_file
      end

      csv = ::CSV.new(output_file, col_sep: "\t")
      csv << used_extensions

      # Stream results and write directly to CSV.
      # find_each automatically orders by dwc_occurrences.id for batching, which
      # matches the order of data.tsv and predicate files for side-by-side paste joining.
      query.find_each(batch_size: 50_000) do |row|
        output_row = []

        # Iterate over column_data to guarantee column order matches
        # used_extensions.
        column_data.each do |source_type, col|
          case source_type
          when :method
            v = row.send(col)
          when :ce
            # Map virtual :id to :collecting_event_id
            attr_name = (col == :id ? :collecting_event_id : col)
            v = row.send(attr_name)
          when :co
            # Map virtual :id to collection_object_id
            attr_name = (col == :id ? :collection_object_id : col)
            v = row.send(attr_name)
          when :dwco
            # Map virtual :id to dwc_occurrence_id
            attr_name = (col == :id ? :dwc_occurrence_id : col)
            v = row.send(attr_name)
          end

          output_row << (v.nil? ? nil : Utilities::Strings.sanitize_for_csv(v.to_s))
        end

        csv << output_row
      end

      Rails.logger.debug 'dwca_export: extension data written'

      csv.flush
      output_file.flush
      output_file.rewind

      Rails.logger.debug 'dwca_export: taxonworks_extension_data prepared'

      output_file
    end

    private

    def collection_object_scope
      @collection_object_scope ||= @core_scope.where(dwc_occurrence_object_type: 'CollectionObject')
    end

    # Builds the SQL query and metadata needed for taxonworks_extension_data export.
    # @return [Hash] with keys:
    #   :query - ActiveRecord::Relation with all needed joins and select columns
    #   :column_data - array of [column_source_type, column_or_method] in CSV order
    #   :used_extensions - array of CSV header names in output order
    def extension_data_query_data
      field_data = classify_extension_fields

      query = build_query_joins(field_data)
      select_cols = build_select_columns(field_data)

      {
        query: query.select(select_cols),
        column_data: field_data[:column_data],
        used_extensions: field_data[:used_extensions]
      }
    end

    # Classifies extension fields into their source types and builds metadata.
    # @return [Hash] with field classifications and metadata arrays
    def classify_extension_fields
      methods = {}
      ce_fields = {}
      co_fields = {}
      dwco_fields = {}
      column_data = []
      used_extensions = []

      @taxonworks_extension_methods.map(&:to_sym).each do |sym|
        csv_header_name = ('TW:Internal:' + sym.to_s).freeze

        if (method = ::CollectionObject::EXTENSION_COMPUTED_FIELDS[sym])
          methods[method] = csv_header_name
          column_data << [:method, method]
          used_extensions << csv_header_name
        elsif (column_name = ::CollectionObject::EXTENSION_CE_FIELDS[sym])
          ce_fields[column_name] = csv_header_name
          column_data << [:ce, column_name]
          used_extensions << csv_header_name
        elsif (column_name = ::CollectionObject::EXTENSION_CO_FIELDS[sym])
          co_fields[column_name] = csv_header_name
          column_data << [:co, column_name]
          used_extensions << csv_header_name
        elsif (column_name = ::CollectionObject::EXTENSION_DWC_OCCURRENCE_FIELDS[sym])
          dwco_fields[column_name] = csv_header_name
          column_data << [:dwco, column_name]
          used_extensions << csv_header_name
        end
      end

      # Extract column arrays for query building (preserve requested order).
      co_columns = co_fields.keys
      ce_columns = ce_fields.keys
      # map virtual :id to :collecting_event_id
      if (idx = ce_columns.index(:id))
        ce_columns[idx] = :collecting_event_id
      end
      dwco_columns = dwco_fields.keys

      {
        methods:,
        ce_columns:,
        co_columns:,
        dwco_columns:,
        column_data:,
        used_extensions:
      }
    end

    # Builds query with necessary joins based on field types.
    # @param field_data [Hash] field classification data from classify_extension_fields
    # @return [ActiveRecord::Relation] query with joins applied
    def build_query_joins(field_data)
      ce_columns = field_data[:ce_columns]
      methods = field_data[:methods]

      query = collection_object_scope
        .joins('JOIN collection_objects ON collection_objects.id = dwc_occurrences.dwc_occurrence_object_id')

      if ce_columns.any?
        query = query.joins('LEFT JOIN collecting_events ON collecting_events.id = collection_objects.collecting_event_id')
      end

      if methods.keys.include?(:otu_name)
        query = query
          .joins('LEFT JOIN taxon_determinations ON taxon_determinations.taxon_determination_object_id = collection_objects.id ' \
                            'AND taxon_determinations.taxon_determination_object_type = \'CollectionObject\' ' \
                            'AND taxon_determinations.position = 1')
          .joins('LEFT JOIN otus ON otus.id = taxon_determinations.otu_id')
      end

      query
    end

    # Builds SELECT clause columns with proper aliasing.
    # @param field_data [Hash] field classification data from classify_extension_fields
    # @return [Array<String>] SELECT column specifications
    def build_select_columns(field_data)
      methods = field_data[:methods]
      ce_columns = field_data[:ce_columns]
      co_columns = field_data[:co_columns]
      dwco_columns = field_data[:dwco_columns]

      select_cols = ['dwc_occurrences.id']

      # Computed fields
      if methods.keys.include?(:otu_name)
        select_cols << 'otus.name AS otu_name'
      end

      # CE fields - map virtual :id column to collecting_event_id
      select_cols += ce_columns.map { |col| col == :collecting_event_id ? "collecting_events.id AS collecting_event_id" : "collecting_events.#{col}" } if ce_columns.any?

      # CO fields - map virtual :id column to collection_object_id
      select_cols += co_columns.map { |col| col == :id ? "collection_objects.id AS collection_object_id" : "collection_objects.#{col}" } if co_columns.any?

      # DWCO fields - map virtual :id column to dwc_occurrence_id
      if dwco_columns.include?(:id)
        select_cols << 'dwc_occurrences.id AS dwc_occurrence_id'
        select_cols += dwco_columns.reject { |col| col == :id }.map { |col| "dwc_occurrences.#{col}" }
      else
        select_cols += dwco_columns.map { |col| "dwc_occurrences.#{col}" } if dwco_columns.any?
      end

      select_cols
    end
  end
end
