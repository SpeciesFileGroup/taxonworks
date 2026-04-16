require 'zip'

module Export::Dwca::Occurrence

  # Columns we include in the Resource Relationship extension table that
  # aren't DwC terms but have meaning for us and perhaps users of our
  # archives.
  LOCAL_RESOURCE_RELATIONSHIP_TERMS = {
    'TW:Resource': 'https://sfg.taxonworks.org/dwc/terms/resourceRelationship/resource',
    'TW:RelatedResource': 'https://sfg.taxonworks.org/dwc/terms/resourceRelationship/relatedResource',
  }.freeze

  # !!
  # !! This export does not support AssertedDistribution data at the moment.  While those data are indexed,
  # !! if they are in the `core_scope` they will almost certainly cause problems or be ignored.
  # !!
  #
  # Wrapper to build DWCA zipfiles for a specific project.
  # See tasks/accesssions/report/dwc_controller.rb for use.
  #
  # With help from http://thinkingeek.com/2013/11/15/create-temporary-zip-file-send-response-rails/
  #
  # Usage:
  #  begin
  #   data = Dwca::Occurrence::Data.new(DwcOccurrence.where(project_id: sessions_current_project_id)
  #  ensure
  #   data.cleanup
  #  end
  #
  # Always use the ensure/data.cleanup pattern!
  #
  class Data
    include Export::Dwca::Occurrence::SqlFragments
    include Export::Dwca::Occurrence::PostgresqlFunctions

    # @return [Tempfile]
    #   The core occurrence CSV data as a tempfile
    attr_accessor :data

    # @return [Hash]
    #   Input configuration containing :dataset and :additional_metadata as xml
    #   strings, for use in construction of the eml file.
    attr_accessor :eml_data

    # @return [Tempfile]
    #   The eml.xml metadata file.
    attr_accessor :eml

    # @return [Tempfile]
    #   The meta.xml file describing the archive structure.
    attr_accessor :meta

    # @return [Tempfile]
    #   The final DwC-A zip archive.
    attr_accessor :zipfile

    # @return [String, ActiveRecord::Relation]
    #   Required. The core DwcOccurrence scope - can be a SQL string or
    #   ActiveRecord::Relation
    attr_accessor :core_scope

    # @return [Integer]
    #   Total number of records in the core scope.
    attr_accessor :total

    # @return [String]
    #   The filename for the zip archive.
    attr_reader :filename

    # @return [Tempfile]
    #   TSV file containing predicate data.
    attr_accessor :predicate_data

    # @return [Hash]
    #   Predicate IDs to include:
    #   { collection_object_predicate_id: [], collecting_event_predicate_id: [] }
    attr_accessor :data_predicate_ids

    # @return [Tempfile]
    #   TSV file containing TaxonWorks extension data.
    attr_accessor :taxonworks_extension_data

    # @return [Array<Symbol>]
    #   List of TaxonWorks-specific field names (e.g., :otu_name,
    #   :elevation_precision) to export as additional columns (subset of
    #   EXTENSION_FIELDS).
    attr_accessor :taxonworks_extension_methods

    # @return [Tempfile]
    #   Combined TSV file with core data, predicate data, and TaxonWorks
    #   extension data joined horizontally.
    attr_accessor :all_data

    # Initializes a new DwC-A export data builder.
    #
    # @param core_scope [String, ActiveRecord::Relation]
    #   Required. DwcOccurrence scope (SQL string or ActiveRecord::Relation).
    # @param extension_scopes [Hash]
    #   Optional extensions to include:
    #   - :biological_associations [Hash] with keys :core_params and
    #     :collection_objects_query
    #   - :media [Hash] with keys :collection_objects (query string) and
    #     :field_occurrences (query string)
    # @param predicate_extensions [Hash]
    #   Predicate IDs to include:
    #   - :collection_object_predicate_id [Array<Integer>]
    #   - :collecting_event_predicate_id [Array<Integer>]
    # @param eml_data [Hash]
    #   EML metadata configuration:
    #   - :dataset [String] XML string for dataset metadata
    #   - :additional_metadata [String] XML string for additional metadata
    # @param taxonworks_extensions [Array<Symbol>]
    #   TaxonWorks-specific fields to export
    #   (e.g., [:otu_name, :elevation_precision]).
    def initialize(
      core_scope: nil, extension_scopes: {}, predicate_extensions: {},
      eml_data: {}, taxonworks_extensions: []
    )
      raise ArgumentError, 'must pass a core_scope' if core_scope.nil?

      @core_scope = core_scope

      @biological_associations_extension = extension_scopes[:biological_associations]
      @media_extension = extension_scopes[:media]

      @data_predicate_ids = { collection_object_predicate_id: [], collecting_event_predicate_id: [] }.merge(predicate_extensions)

      @eml_data = eml_data

      # Normalize and sort extensions into a fixed, canonical order.
      extensions = Array(taxonworks_extensions).map(&:to_sym)
      canonical  = ::CollectionObject::DwcExtensions::TaxonworksExtensions::EXTENSION_FIELDS

      @taxonworks_extension_methods = canonical & extensions
    end

    # Normalizes and returns the core scope as an ordered ActiveRecord::Relation.
    # @return [ActiveRecord::Relation] DwcOccurrence scope ordered by id
    def core_scope
      if @core_scope.kind_of?(String)
        ::DwcOccurrence.from('(' + @core_scope + ') as dwc_occurrences').order('dwc_occurrences.id')
      elsif @core_scope.kind_of?(ActiveRecord::Relation)
        raise ArgumentError, 'core_scope: is not a DwcOccurrence relation' unless @core_scope.table.name == 'dwc_occurrences'

        @core_scope.order('dwc_occurrences.id')
      else
        raise ArgumentError, 'Scope is not a SQL string or ActiveRecord::Relation'
      end
    end

    def collection_object_predicate_ids
      @data_predicate_ids[:collection_object_predicate_id]
    end

    def collecting_event_predicate_ids
      @data_predicate_ids[:collecting_event_predicate_id]
    end

    # Transforms the biological associations config into an AR scope.
    # @return [ActiveRecord::Relation, nil] BiologicalAssociation scope with
    #   biological_association_index, or nil if not configured.
    def biological_associations_scope
      return nil unless @biological_associations_extension.present?

      q = @biological_associations_extension[:collection_objects_query]
      scope = if q.kind_of?(String)
        ::BiologicalAssociation.from('(' + q + ') as biological_associations')
      elsif q.kind_of?(ActiveRecord::Relation)
        q
      else
        raise ArgumentError, 'Biological associations scope is not an SQL string or ActiveRecord::Relation'
      end

      scope
        .joins(:biological_association_index)
        .select('biological_associations.id')
        .includes(:biological_association_index)
    end

    def predicate_options_present?
      data_predicate_ids[:collection_object_predicate_id].present? || data_predicate_ids[:collecting_event_predicate_id].present?
    end

    def taxonworks_options_present?
      taxonworks_extension_methods.present?
    end

    def total
      @total ||= core_scope.unscope(:order).size
    end

    # Streams CSV data from PostgreSQL directly to output_file.
    # @param output_file [File, Tempfile] File to write to directly
    def csv(output_file:)
      conn = ActiveRecord::Base.connection

      create_csv_sanitize_function

      target_cols = ::DwcOccurrence.target_columns
      excluded = ::DwcOccurrence.excluded_columns

      cols_to_export = target_cols - excluded

      cols_with_data = columns_with_data(cols_to_export)

      column_order = (::CollectionObject::DWC_OCCURRENCE_MAP.keys +
        ::CollectionObject::EXTENSION_FIELDS).map(&:to_s)
      ordered_cols = order_columns(cols_with_data, column_order)

      column_types = ::DwcOccurrence.columns_hash

      # Build SELECT list with proper column names and aliases.
      # Sanitize string columns by replacing newlines and tabs with spaces
      # (matching Utilities::Strings.sanitize_for_csv behavior).
      select_list = ordered_cols.map do |col|
        if col == 'id'
          # DwCA requires the <id> column specified in meta.xml to be named "id"
          # (not "occurrenceID") for extension records to join correctly (see
          # commit 444262503d).
          # We copy the occurrenceID column to the id so that id's are proper
          # UUIDs (not db ids), then also include occurrenceID as a proper DwC
          # term field. This means both columns contain the same values - it
          # seems to be required in this case.
          '"occurrenceID" AS "id"'
        elsif col == 'dwcClass'
          # Header converter: dwcClass -> class, with sanitization
          '"dwcClass" AS "class"'
        else
          column_info = column_types[col]
          is_string_column = column_info && [:string, :text].include?(column_info.type)

          if is_string_column
            # String columns - sanitize by replacing newlines and tabs.
            "pg_temp.sanitize_csv(#{conn.quote_column_name(col)}) AS #{conn.quote_column_name(col)}"
          else
            # Non-string columns (integer, decimal, date, etc.) - no
            # sanitization needed.
            conn.quote_column_name(col)
          end
        end
      end.join(', ')

      copy_sql = <<-SQL
        COPY (
          SELECT #{select_list}
          FROM (#{core_scope.to_sql}) AS dwc_data
        ) TO STDOUT WITH (FORMAT CSV, DELIMITER E'\\t', HEADER, NULL '')
      SQL

      # Stream directly from PostgreSQL to file
      conn.raw_connection.copy_data(copy_sql) do
        while row = conn.raw_connection.get_copy_data
          output_file.write(row.force_encoding(Encoding::UTF_8))
        end
      end

      Rails.logger.debug 'dwca_export: csv data generated'
    end

    # Find which columns in the dwc_occurrence table have non-NULL, non-empty
    # values.
    # This implements the trim_columns: true behavior.
    # Note: We check for non-empty AFTER sanitization.
    def columns_with_data(columns)
      return [] if columns.empty?

      conn = ActiveRecord::Base.connection

      column_types = ::DwcOccurrence.columns_hash

      checks = columns.map.with_index do |col, idx|
        quoted = conn.quote_column_name(col)
        col_str = col.to_s
        column_info = column_types[col_str]

        is_string_column = column_info && [:string, :text].include?(column_info.type)
        if is_string_column
          # String columns - check if any non-empty values after sanitization.
          sanitized = "pg_temp.sanitize_csv(#{quoted})"
          "CASE WHEN COUNT(CASE WHEN #{sanitized} IS NOT NULL AND #{sanitized} != '' THEN 1 END) > 0 THEN #{conn.quote(col)} ELSE NULL END AS check_#{idx}"
        else
          # Non-string columns - just check if not NULL.
          "CASE WHEN COUNT(#{quoted}) > 0 THEN #{conn.quote(col_str)} ELSE NULL END AS check_#{idx}"
        end
      end

      sql = "SELECT #{checks.join(', ')} FROM (#{core_scope.to_sql}) AS data"
      result = conn.execute(sql).first
      result.values.compact
    end

    # Order columns according to column_order, with unordered columns first.
    # This matches the behavior of Export::CSV.sort_column_headers.
    def order_columns(columns, column_order)
      sorted = []
      unsorted = []

      columns.each do |col|
        if pos = column_order.index(col)
          sorted[pos] = col
        else
          unsorted.push col
        end
      end

      unsorted + sorted.compact
    end

    # @return [Boolean]
    #   true if provided core_scope returns no records.
    def no_records?
      total == 0
    end

    # Generates and caches the core occurrence data as TSV.
    # @return [Tempfile] The core occurrence CSV data as a tempfile.
    def data
      return @data if @data

      @data = Tempfile.new('data.tsv')

      if no_records?
        @data.write("\n")
      else
        csv(output_file: @data)
      end

      @data.flush
      @data.rewind

      Rails.logger.debug 'dwca_export: data written'

      @data
    end

    # Generates and caches TaxonWorks extension data as TSV.
    # @return [Tempfile] TSV file with TaxonWorks-specific extension fields.
    def taxonworks_extension_data
      return @taxonworks_extension_data if @taxonworks_extension_data

      @taxonworks_extension_data = Tempfile.new('tw_extension_data.tsv')

      exporter = Export::Dwca::Occurrence::TaxonworksExtensionExporter.new(
        core_scope: core_scope,
        taxonworks_extension_methods: taxonworks_extension_methods
      )
      exporter.export_to(@taxonworks_extension_data)

      @taxonworks_extension_data
    end

    # Generates and caches predicate data as TSV.
    # @return [Tempfile] TSV file with predicate data columns.
    def predicate_data
      return @predicate_data if @predicate_data

      @predicate_data = Tempfile.new('predicate_data.tsv')

      exporter = Export::Dwca::Occurrence::PredicateExporter.new(
        core_scope: core_scope,
        collection_object_predicate_ids: collection_object_predicate_ids,
        collecting_event_predicate_ids: collecting_event_predicate_ids
      )
      exporter.export_to(@predicate_data)

      @predicate_data
    end

    # Generates and caches the combined data file by joining core, predicate,
    # and extension data horizontally.
    # @return [Tempfile] Combined TSV file with all data joined side-by-side.
    def all_data
      return @all_data if @all_data

      Rails.logger.debug 'dwca_export: start combining all data'

      @all_data = Tempfile.new('data.tsv')

      join_data = [data] # to become data.tsv

      if predicate_options_present?
        join_data.push(predicate_data)
      end

      if taxonworks_options_present?
        join_data.push(taxonworks_extension_data)
      end

      if join_data.size > 1
        # TODO: might not need to check size at some point.
        # Only join files that aren't empty, prevents paste from adding an empty column header when empty.
        @all_data.write(`paste #{ join_data.filter_map{|f| f.path if f.size > 0}.join(' ')}`)
      else
        @all_data.write(data.read)
      end

      @all_data.flush
      @all_data.rewind

      Rails.logger.debug 'dwca_export: all_data written'

      @all_data
    end

    # Generates and caches the eml.xml file.
    # @return [Tempfile] The EML metadata file (uses stub if no eml_data provided)
    # @note This is a stub implementation, users may prefer to use IPT.
    # @see https://github.com/gbif/ipt/wiki/resourceMetadata
    # @see https://github.com/gbif/ipt/wiki/resourceMetadata#exemplar-datasets
    # TODO: reference biological_resource_extension.csv
    def eml
      return @eml if @eml
      @eml = Tempfile.new('eml.xml')

      if eml_data[:dataset].present? || eml_data[:additional_metadata].present?
        eml_xml = ::Export::Dwca::Eml.actualized_eml_for(
          eml_data[:dataset], eml_data[:additional_metadata]
        )
      else
        eml_xml = ::Export::Dwca::Eml.actualized_stub_eml
      end

      @eml.write(eml_xml)
      @eml.flush
      @eml
    end

    def biological_association_relations_to_core
      core_params = {
        dwc_occurrence_query: @biological_associations_extension[:core_params]
      }

      subject_biological_associations =
        ::Queries::BiologicalAssociation::Filter.new(
          collection_object_query: core_params,
          collection_object_as_subject_or_as_object: :subject
        ).all

      object_biological_associations =
        ::Queries::BiologicalAssociation::Filter.new(
          collection_object_query: core_params,
          collection_object_as_subject_or_as_object: :object
        ).all

      {
        subject: Set.new(subject_biological_associations.pluck(:id)),
        object: Set.new(object_biological_associations.pluck(:id))
      }
    end

    def biological_associations_resource_relationship_tmp
      return nil if @biological_associations_extension.nil?

      @biological_associations_resource_relationship_tmp = Tempfile.new('biological_resource_relationship.tsv')

      if no_records?
        @biological_associations_resource_relationship_tmp.write("\n")
      else
        Export::CSV::Dwc::Extension::BiologicalAssociations.csv(
          biological_associations_scope,
          biological_association_relations_to_core,
          output_file: @biological_associations_resource_relationship_tmp
        )
      end

      @biological_associations_resource_relationship_tmp.flush
      @biological_associations_resource_relationship_tmp.rewind
      @biological_associations_resource_relationship_tmp
    end

    def media_tmp
      return nil if @media_extension.nil?

      @media_tmp = Tempfile.new('media.tsv')

      if no_records?
        @media_tmp.write("\n")
      else
        exporter = Export::Dwca::Occurrence::MediaExporter.new(
          media_extension: @media_extension,
        )
        exporter.export_to(@media_tmp)
      end

      @media_tmp.flush
      @media_tmp.rewind
      @media_tmp
    end

    # @return [Array] use the temporarily written, and refined, CSV file to read
    #   off the existing headers so we can use them in writing meta.yml.
    # Non-standard DwC colums are handled elsewhere.
    def meta_fields
      return [] if no_records?
      h = File.open(all_data, &:gets)&.strip&.split("\t")
      # Remove "id" column from field list since it's declared separately as
      # <id> in meta.xml.
      # The remaining fields become <field> elements.
      h&.shift
      h || []
    end

    # Generates and caches the meta.xml file describing the DwC-A structure.
    # @return [Tempfile] The meta.xml file with core and extension definitions.
    def meta
      return @meta if @meta

      @meta = Tempfile.new('meta.xml')

      builder = Nokogiri::XML::Builder.new do |xml|
        xml.archive('xmlns' => 'http://rs.tdwg.org/dwc/text/') {
          # Core
          xml.core(encoding: 'UTF-8', linesTerminatedBy: '\n', fieldsTerminatedBy: '\t', fieldsEnclosedBy: '"', ignoreHeaderLines: '1', rowType:'http://rs.tdwg.org/dwc/terms/Occurrence') {
            xml.files {
              xml.location 'data.tsv'
            }
            # The column at the index indicated here must be literally named
            # "id" in the TSV for DwCA extension joins to work (it seems).
            xml.id(index: 0)
            meta_fields.each_with_index do |h,i|
              if h =~ /TW:/ # All TW headers have ':'
                xml.field(index: i+1, term: h)
              else
                xml.field(index: i+1, term: DwcOccurrence::DC_NAMESPACE + h)
              end
            end
          }

          # Resource relationship (biological associations)
          if !@biological_associations_extension.nil?
            xml.extension(encoding: 'UTF-8', linesTerminatedBy: '\n', fieldsTerminatedBy: '\t', fieldsEnclosedBy: '"', ignoreHeaderLines: '1', rowType:'http://rs.tdwg.org/dwc/terms/ResourceRelationship') {
              xml.files {
                xml.location 'resource_relationships.tsv'
              }
              Export::CSV::Dwc::Extension::BiologicalAssociations::HEADERS_NAMESPACES.each_with_index do |n, i|
                if i == 0
                  n == '' || (raise TaxonWorks::Error, "First resource relationship column (coreid) should have namespace '', got '#{n}'")
                  xml.coreid(index: 0)
                else
                  xml.field(index: i, term: n)
                end
              end
            }
          end

          # Media (images, sounds)
          if !@media_extension.nil?
            xml.extension(encoding: 'UTF-8', linesTerminatedBy: '\n', fieldsTerminatedBy: '\t', fieldsEnclosedBy: '"', ignoreHeaderLines: '1', rowType:'http://rs.tdwg.org/ac/terms/Multimedia') {
              xml.files {
                xml.location 'media.tsv'
              }
              Export::CSV::Dwc::Extension::Media::HEADERS_NAMESPACES.each_with_index do |n, i|
                if i == 0
                  n == '' || (raise TaxonWorks::Error, "First media column (coreid) should have namespace '', got '#{n}'")
                  xml.coreid(index: 0)
                else
                  xml.field(index: i, term: n)
                end
              end
            }
          end
        }
      end

      @meta.write(builder.to_xml)
      @meta.flush
      @meta
    end

    def build_zip
      t = Tempfile.new(filename)

      Zip::OutputStream.open(t) { |zos| }

      Zip::File.open(t.path, create: true) do |zip|
        zip.add('data.tsv', all_data.path)

        zip.add('media.tsv', media_tmp.path) if @media_extension
        zip.add('resource_relationships.tsv', biological_associations_resource_relationship_tmp.path) if @biological_associations_extension

        zip.add('meta.xml', meta.path)
        zip.add('eml.xml', eml.path)
      end
      t
    end

    # Generates and caches the final DwC-A zip archive.
    # @return [Tempfile] The complete DwC-A zip file.
    def zipfile
      if @zipfile.nil?
        @zipfile = build_zip
      end
      @zipfile
    end

    # Generates and caches the filename for the zip archive.
    # @return [String] The filename with timestamp.
    def filename
      @filename ||= "dwc_occurrences_#{DateTime.now}.zip"
      @filename
    end

    # @return [True]
    #   close and delete all temporary files.
    def cleanup

      Rails.logger.debug 'dwca_export: cleanup start'

      # Only cleanup files that were actually created (materialized).
      # This prevents lazy-loading during cleanup.
      if defined?(@zipfile) && @zipfile
        @zipfile.close
        @zipfile.unlink
      end

      if defined?(@meta) && @meta
        @meta.close
        @meta.unlink
      end

      if defined?(@eml) && @eml
        @eml.close
        @eml.unlink
      end

      if defined?(@data) && @data
        @data.close
        @data.unlink
      end

      if @biological_associations_extension && defined?(@biological_associations_resource_relationship_tmp) && @biological_associations_resource_relationship_tmp
        @biological_associations_resource_relationship_tmp.close
        @biological_associations_resource_relationship_tmp.unlink
      end

      if @media_extension && defined?(@media_tmp) && @media_tmp
        @media_tmp.close
        @media_tmp.unlink
      end

      if predicate_options_present? && defined?(@predicate_data) && @predicate_data
        @predicate_data.close
        @predicate_data.unlink
      end

      if taxonworks_options_present? && defined?(@taxonworks_extension_data) && @taxonworks_extension_data
        @taxonworks_extension_data.close
        @taxonworks_extension_data.unlink
      end

      if defined?(@all_data) && @all_data
        @all_data.close
        @all_data.unlink
      end

      Rails.logger.debug 'dwca_export: cleanup end'

      true
    end

    # @param download [a Download]
    def package_download(download)
      p = zipfile.path

      # This doesn't touch the db (source_file_path is an instance var).
      download.update!(source_file_path: p)
    end

  end
end
