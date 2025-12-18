require 'zip'

module Export::Dwca

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
  #   data = Dwca::Data.new(DwcOccurrence.where(project_id: sessions_current_project_id)
  #  ensure
  #   data.cleanup
  #  end
  #
  # Always use the ensure/data.cleanup pattern!
  #
  class Data

    attr_accessor :data

    # @return [Hash] containing dataset and additional_metadata, as xml strings,
    # for use in construction of the eml file.
    attr_accessor :eml_data

    attr_accessor :eml

    attr_accessor :meta

    attr_accessor :zipfile

    # @return [Scope]
    #  Required.  Of DwcOccurrence
    attr_accessor :core_scope

    # @return [Hash] Hash with keys core_params (i.e. just the params for
    # core_scope), collection_objects_query
    attr_accessor :biological_associations_extension

    # @return [Hash] of collection_objects: query_string, field_occurrences: query_string
    attr_accessor :media_extension

    attr_accessor :total #TODO update

    attr_reader :filename

    attr_accessor :predicate_data

    # @return Hash
    # collection_object_predicate_id: [], collecting_event_predicate_id: []
    attr_accessor :data_predicate_ids

    # @return Array
    attr_accessor :taxonworks_extension_data

    # @return Array<Symbol>
    attr_accessor :taxonworks_extension_methods

    # A Tempfile, core records and predicate data (and maybe more in future) joined together in one file
    attr_accessor :all_data

    # TODO: fails when we get to AssertedDistribution
    #  A lookup with the id pointing to the position
    attr_accessor :dwc_id_order

    # @param [Array<Symbol>] taxonworks_extensions List of methods to perform on each CO
    def initialize(core_scope: nil, extension_scopes: {}, predicate_extensions: {}, eml_data: {}, taxonworks_extensions: [])
      raise ArgumentError, 'must pass a core_scope' if core_scope.nil?

      @core_scope = core_scope

      @biological_associations_extension = extension_scopes[:biological_associations] #! Hash with keys core_params (i.e. core_scope params), collection_objects_query
      @media_extension = extension_scopes[:media] #! Hash with keys collection_objects, field_occurrences

      @data_predicate_ids = { collection_object_predicate_id: [], collecting_event_predicate_id: [] }.merge(predicate_extensions)

      @eml_data = eml_data

       # Normalize and sort extensions into a fixed, canonical order
      extensions = Array(taxonworks_extensions).map(&:to_sym)
      canonical  = ::CollectionObject::DwcExtensions::TaxonworksExtensions::EXTENSION_FIELDS

      # Orders caller's extension in the canonical order.
      @taxonworks_extension_methods = canonical & extensions

    end

    # !params core_scope [String, ActiveRecord::Relation]
    #   String is fully formed SQL
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

    def biological_associations_extension
      return nil unless @biological_associations_extension.present?

      q = @biological_associations_extension[:collection_objects_query]
      scope = if q.kind_of?(String)
        ::BiologicalAssociation.from('(' + q + ') as biological_associations')
      elsif q.kind_of?(ActiveRecord::Relation)
        q
      else
        raise ArgumentError, 'Biological associations scope is not an SQL string or ActiveRecord::Relation'
      end

      scope.select('biological_associations.id')
        .includes(:biological_association_index)
    end

    def media_extension
      return nil unless @media_extension.present?

      collection_objects = ::CollectionObject.none
      if @media_extension[:collection_objects]
        collection_objects = ::CollectionObject
          .from('(' + @media_extension[:collection_objects] + ') AS collection_objects')
          .includes(:images, :sounds, observations: :images, taxon_determination: {otu: :taxon_name})
      end

      field_occurrences = ::FieldOccurrence.none
      if @media_extension[:field_occurrences]
        field_occurrences = ::FieldOccurrence
          .from('(' + @media_extension[:field_occurrences] + ') AS field_occurrences')
          .includes(:images, :sounds, observations: :images, taxon_determination: {otu: :taxon_name})
      end

      {
        collection_objects:,
        field_occurrences:
      }
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

    # Streams CSV data from PostgreSQL directly to output_file
    # @param output_file [File, Tempfile] File to write to directly
    def csv(output_file:)
      conn = ActiveRecord::Base.connection

      # Create temporary function for sanitizing CSV values
      create_csv_sanitize_function

      target_cols = ::DwcOccurrence.target_columns
      excluded = ::DwcOccurrence.excluded_columns

      cols_to_export = target_cols - excluded

      cols_with_data = columns_with_data(cols_to_export)

      column_order = (::CollectionObject::DWC_OCCURRENCE_MAP.keys + ::CollectionObject::EXTENSION_FIELDS).map(&:to_s)
      ordered_cols = order_columns(cols_with_data, column_order)

      column_types = ::DwcOccurrence.columns_hash

      # Build SELECT list with proper column names and aliases
      # Sanitize string columns by replacing newlines and tabs with spaces (matching Utilities::Strings.sanitize_for_csv behavior)
      select_list = ordered_cols.map do |col|
        if col == 'id'
          # id is copied from occurrenceID (string), with sanitization
          "pg_temp.sanitize_csv(\"occurrenceID\") AS \"id\""
        elsif col == 'dwcClass'
          # Header converter: dwcClass -> class, with sanitization
          "pg_temp.sanitize_csv(\"dwcClass\") AS \"class\""
        else
          column_info = column_types[col]
          is_string_column = column_info && [:string, :text].include?(column_info.type)

          if is_string_column
            # String columns - sanitize by replacing newlines and tabs
            "pg_temp.sanitize_csv(#{conn.quote_column_name(col)}) AS #{conn.quote_column_name(col)}"
          else
            # Non-string columns (integer, decimal, date, etc.) - no sanitization needed
            conn.quote_column_name(col)
          end
        end
      end.join(', ')

      # Build COPY TO query
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

    # Creates a temporary PostgreSQL function for sanitizing CSV values
    # The function removes newlines and tabs from text, replacing them with spaces.
    # The function exists only for the current database session.
    def create_csv_sanitize_function
      conn = ActiveRecord::Base.connection
      conn.execute(<<~SQL)
        CREATE OR REPLACE FUNCTION pg_temp.sanitize_csv(text)
        RETURNS text AS $$
          SELECT REGEXP_REPLACE($1, E'[\\n\\t]', ' ', 'g')
        $$ LANGUAGE SQL IMMUTABLE;
      SQL
    end

    # Creates a temporary PostgreSQL function that formats an array of names
    # into a grammatically correct sentence, matching Utilities::Strings.authorship_sentence
    # Examples:
    #   1 name: "Smith"
    #   2 names: "Smith & Jones"
    #   3+ names: "Smith, Jones & Brown"
    # The function exists only for the current database session.
    def create_authorship_sentence_function
      conn = ActiveRecord::Base.connection
      conn.execute(<<~SQL)
        CREATE OR REPLACE FUNCTION pg_temp.authorship_sentence(names text[])
        RETURNS text AS $$
          SELECT CASE
            WHEN array_length(names, 1) IS NULL THEN NULL
            WHEN array_length(names, 1) = 1 THEN names[1]
            WHEN array_length(names, 1) = 2 THEN names[1] || ' & ' || names[2]
            ELSE array_to_string(names[1:array_length(names,1)-1], ', ') || ' & ' || names[array_length(names,1)]
          END
        $$ LANGUAGE SQL IMMUTABLE;
      SQL
    end

    # Find which columns in the dwc_occurrence table have non-NULL, non-empty values
    # This implements the trim_columns: true behavior
    # Note: We check for non-empty AFTER sanitization
    def columns_with_data(columns)
      return [] if columns.empty?

      conn = ActiveRecord::Base.connection

      # Get column type information from the database
      column_types = ::DwcOccurrence.columns_hash

      # For each column, check if it has any non-NULL, non-empty values after sanitization
      checks = columns.map.with_index do |col, idx|
        quoted = conn.quote_column_name(col)
        col_str = col.to_s
        column_info = column_types[col_str]

        # Determine if this is a string/text column
        is_string_column = column_info && [:string, :text].include?(column_info.type)

        if is_string_column
          # String columns - check if any non-empty values after sanitization
          sanitized = "pg_temp.sanitize_csv(#{quoted})"
          "CASE WHEN COUNT(CASE WHEN #{sanitized} IS NOT NULL AND #{sanitized} != '' THEN 1 END) > 0 THEN #{conn.quote(col)} ELSE NULL END AS check_#{idx}"
        else
          # Non-string columns - just check if not NULL
          "CASE WHEN COUNT(#{quoted}) > 0 THEN #{conn.quote(col_str)} ELSE NULL END AS check_#{idx}"
        end
      end

      sql = "SELECT #{checks.join(', ')} FROM (#{core_scope.to_sql}) AS data"
      result = conn.execute(sql).first
      result.values.compact
    end

    # Order columns according to column_order, with unordered columns first
    # This matches the behavior of Export::CSV.sort_column_headers
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
    #   true if provided core_scope returns no records
    def no_records?
      total == 0
    end

    # @return [Tempfile]
    #   the csv data as a tempfile
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

    # Returns a relation of dwc_occurrences for CollectionObjects in the export,
    # ordered by dwc_occurrences.id to match the core file order.
    # This avoids materializing all IDs in Ruby memory.
    # @return [ActiveRecord::Relation]
    def collection_object_scope
      @collection_object_scope ||= core_scope.where(dwc_occurrence_object_type: 'CollectionObject')
    end

      # rubocop:disable Metrics/MethodLength

    # Writes the TaxonWorks extension file by streaming directly to a Tempfile
    # in the same order as the core file.
    def taxonworks_extension_data
      return @taxonworks_extension_data if @taxonworks_extension_data

      data = extension_data_query_data
      query = data[:query]
      column_data = data[:column_data]
      used_extensions = data[:used_extensions]

      if used_extensions.empty? || !collection_object_scope.exists?
        @taxonworks_extension_data = Tempfile.new('tw_extension_data.tsv')
        Rails.logger.debug 'dwca_export: taxonworks_extension_data prepared - ' + (used_extensions.empty? ? 'no extensions' : 'no collection objects')
        return @taxonworks_extension_data
      end

      @taxonworks_extension_data = Tempfile.new('tw_extension_data.tsv')
      csv = CSV.new(@taxonworks_extension_data, col_sep: "\t")
      csv << used_extensions

      # Stream results and write directly to CSV
      # Iterate over fields array to guarantee order matches used_extensions
      query.find_each(batch_size: 10_000) do |row|
        output_row = []

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
      @taxonworks_extension_data.flush
      @taxonworks_extension_data.rewind

      Rails.logger.debug 'dwca_export: taxonworks_extension_data prepared'

      @taxonworks_extension_data
    end

    # Builds the SQL query and metadata needed for taxonworks_extension_data export.
    # @return [Hash] with keys:
    #   :query - ActiveRecord::Relation with all needed joins and select columns
    #   :fields - array of [column_source_type, column_or_method] in CSV order
    #   :used_extensions - array of CSV header names in output order
    def extension_data_query_data
      # hash of internal method name => csv header name
      methods = {}

      # hash of column_name => csv header name
      ce_fields = {}
      co_fields = {}
      dwco_fields = {}

      # Build ordered arrays as we process extension methods
      # fields: [source_type, column_or_method] in CSV order
      # used_extensions: CSV header names in same order
      column_data = []
      used_extensions = []

      taxonworks_extension_methods.map(&:to_sym).each do |sym|
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

      # Extract column arrays for query building (preserve requested order)
      co_columns    = co_fields.keys
      ce_columns    = ce_fields.keys
      # map virtual :id to :collecting_event_id
      if (idx = ce_columns.index(:id))
        ce_columns[idx] = :collecting_event_id
      end
      dwco_columns  = dwco_fields.keys

      # Build a single joined query to compute all csv fields (database columns
      # + computed fields).
      # !! This scope comes ordered by dwco.id - *this is what determines csv
      # row order, so don't lose it. !!
      query = collection_object_scope
        .joins('JOIN collection_objects ON collection_objects.id = dwc_occurrences.dwc_occurrence_object_id')

      # Add collecting_events join if needed
      if ce_columns.any?
        query = query.joins('LEFT JOIN collecting_events ON collecting_events.id = collection_objects.collecting_event_id')
      end

      # Buildup a select clause from used_extensions columns
      select_cols = ['dwc_occurrences.id']

      # !! Add here as needed for future computed fields.
      if methods.keys.include?(:otu_name)
        select_cols << 'otus.name AS otu_name'

        query = query
          .joins('LEFT JOIN taxon_determinations ON taxon_determinations.taxon_determination_object_id = collection_objects.id ' \
                            'AND taxon_determinations.taxon_determination_object_type = \'CollectionObject\' ' \
                            'AND taxon_determinations.position = 1')
          .joins('LEFT JOIN otus ON otus.id = taxon_determinations.otu_id')
      end

      # CE fields - map virtual :id column to collecting_event_id
      select_cols += ce_columns.map { |col| col == :collecting_event_id ? "collecting_events.id AS collecting_event_id" : "collecting_events.#{col}" } if ce_columns.any?

      # CO fields - map virtual :id column to collection_object_id
      select_cols += co_columns.map { |col| col == :id ? "collection_objects.id AS collection_object_id" : "collection_objects.#{col}" } if co_columns.any?

      # DWCO fields - map virtual :id column to dwc_occurrence_id
      # Note: dwc_occurrences.id is already selected above for find_each, so if :id is in dwco_columns
      # we also need to alias it for data output
      if dwco_columns.include?(:id)
        select_cols << 'dwc_occurrences.id AS dwc_occurrence_id'
        select_cols += dwco_columns.reject { |col| col == :id }.map { |col| "dwc_occurrences.#{col}" }
      else
        select_cols += dwco_columns.map { |col| "dwc_occurrences.#{col}" } if dwco_columns.any?
      end

      {
        query: query.select(select_cols),
        column_data:,
        used_extensions:
      }
    end

    # rubocop:enable Metrics/MethodLength

    def collecting_events
      ::CollectingEvent
        .with(co_scoped: collection_objects.unscope(:order).select(:id, :collecting_event_id))
        .joins('JOIN co_scoped ON co_scoped.collecting_event_id = collecting_events.id')
        .distinct
    end

    def collection_object_attributes_query
      ::InternalAttribute
        .with(touched_collection_objects: collection_objects.unscope(:order).select(:id))
        .joins("JOIN touched_collection_objects ON data_attributes.attribute_subject_id = touched_collection_objects.id AND data_attributes.attribute_subject_type = 'CollectionObject'")
        .joins(:predicate)
        .where(controlled_vocabulary_term_id: collection_object_predicate_ids)
    end

    def collection_object_attributes
      q = "WITH relevant_collection_objects AS (
          #{collection_objects.unscope(:order).select(:id).to_sql}
      )
      SELECT da.id, da.attribute_subject_id,
             CONCAT('TW:DataAttribute:CollectionObject:', cvt.name) AS predicate,
             da.value,
             da.controlled_vocabulary_term_id
      FROM data_attributes da
      JOIN relevant_collection_objects rco ON da.attribute_subject_id = rco.id
                                           AND da.attribute_subject_type = 'CollectionObject'
      JOIN controlled_vocabulary_terms cvt ON cvt.id = da.controlled_vocabulary_term_id
                                           AND cvt.type = 'Predicate'
      WHERE da.type = 'InternalAttribute'"

      q = q + " AND da.controlled_vocabulary_term_id IN (#{collection_object_predicate_ids.join(',')})" if collection_object_predicate_ids.any?

      DataAttribute.connection.execute( q ).collect{|r| [r['attribute_subject_id'], r['predicate'], r['value']] }
    end

    # @return Relation
    #   the unique attributes derived from CollectingEvents
    def collecting_event_attributes_query
      ::InternalAttribute
        .with(touched_collecting_events: collecting_events)
        .joins("JOIN touched_collecting_events ON data_attributes.attribute_subject_id = touched_collecting_events.id AND data_attributes.attribute_subject_type = 'CollectingEvent'")
        .where(controlled_vocabulary_term_id: collecting_event_predicate_ids)
    end

    #   @return Array
    #     1 row per CO per DA (type) on CE
    def collecting_event_attributes
      q = "WITH relevant_collection_objects AS (
          #{collection_objects.unscope(:order).select(:id, :collecting_event_id).to_sql}
      )

      SELECT
          relevant_collection_objects.id AS co_id,
          CONCAT('TW:DataAttribute:CollectingEvent:', cvt.name) AS predicate,
          da.value
      FROM
          data_attributes da
          JOIN collecting_events ce ON ce.id = da.attribute_subject_id
               AND da.attribute_subject_type = 'CollectingEvent'
               AND da.type = 'InternalAttribute'
          LEFT JOIN relevant_collection_objects ON ce.id = relevant_collection_objects.collecting_event_id
          JOIN controlled_vocabulary_terms cvt ON cvt.id = da.controlled_vocabulary_term_id
              AND cvt.type = 'Predicate'
      WHERE relevant_collection_objects.id IS NOT null"

      q = q + " AND da.controlled_vocabulary_term_id IN (#{collecting_event_predicate_ids.join(',')})" if collecting_event_predicate_ids.any?

      DataAttribute.connection.execute( q ).collect{|r| [r['co_id'], r['predicate'], r['value']] }
    end

    def collection_objects
      ::CollectionObject
        .with(dwc_scoped: core_scope.unscope(:order).select(:dwc_occurrence_object_id, :dwc_occurrence_object_type))
        .joins("JOIN dwc_scoped ON dwc_scoped.dwc_occurrence_object_id = collection_objects.id AND dwc_scoped.dwc_occurrence_object_type = 'CollectionObject'")
        .select(:id, :collecting_event_id, :type)
    end


    # Finds which predicate columns in the temp table actually have non-NULL
    # values. This is called after create_pivoted_predicate_table to filter out
    # empty columns - much faster than scanning data_attributes table.
    def predicates_with_data
      return [] if all_possible_predicates.empty?

      conn = ActiveRecord::Base.connection

      # For each predicate column, check if it has any non-NULL values
      # COUNT(column) only counts non-NULL values, so if it's > 0, we have data
      checks = all_possible_predicates.map.with_index do |pred, idx|
        quoted = conn.quote_column_name(pred)
        # COUNT only counts non-NULL, so > 0 means there's at least one value
        # Need to alias each CASE or they'll all have the same key "case"
        "CASE WHEN COUNT(#{quoted}) > 0 THEN #{conn.quote(pred)} ELSE NULL END AS check_#{idx}"
      end

      sql = "SELECT #{checks.join(', ')} FROM temp_predicate_pivot"

      result = conn.execute(sql).first
      result.values.compact
    end

    # All possible predicates based on configuration (not filtered by actual usage)
    def all_possible_predicates
      @all_possible_predicates ||= begin
        co_preds = collection_object_predicate_ids.empty? ? [] :
          ControlledVocabularyTerm
            .where(id: collection_object_predicate_ids)
            .order(:name)
            .pluck(:name)
            .map { |name| "TW:DataAttribute:CollectionObject:#{name}" }

        ce_preds = collecting_event_predicate_ids.empty? ? [] :
          ControlledVocabularyTerm
            .where(id: collecting_event_predicate_ids)
            .order(:name)
            .pluck(:name)
            .map { |name| "TW:DataAttribute:CollectingEvent:#{name}" }

        co_preds + ce_preds
      end
    end

    # @return [Hash]
    #   Maps cvt_id => full predicate name for collection object predicates
    #   e.g., {123 => "TW:DataAttribute:CollectionObject:foo"}
    def collection_object_predicate_names
      return {} if collection_object_predicate_ids.empty?

      q = "SELECT id, CONCAT('TW:DataAttribute:CollectionObject:', name) AS predicate_name
           FROM controlled_vocabulary_terms
           WHERE id IN (#{collection_object_predicate_ids.join(',')})"

      ActiveRecord::Base.connection.execute(q).each_with_object({}) do |row, hash|
        hash[row['id'].to_i] = row['predicate_name']
      end
    end

    # @return [Hash]
    #   Maps cvt_id => full predicate name for collecting event predicates
    #   e.g., {456 => "TW:DataAttribute:CollectingEvent:bar"}
    def collecting_event_predicate_names
      return {} if collecting_event_predicate_ids.empty?

      q = "SELECT id, name
           FROM controlled_vocabulary_terms
           WHERE id IN (#{collecting_event_predicate_ids.join(',')})"

      ActiveRecord::Base.connection.execute(q).each_with_object({}) do |row, hash|
        hash[row['id'].to_i] = "TW:DataAttribute:CollectingEvent:#{row['name']}"
      end
    end

    # Creates a temporary table with one row per collection object
    # and one column per predicate (pivoted from tall to wide format)
    def create_pivoted_predicate_table
      conn = ActiveRecord::Base.connection

      # Drop if exists (in case method called multiple times)
      conn.execute("DROP TABLE IF EXISTS temp_predicate_pivot")
      conn.execute("DROP TABLE IF EXISTS temp_co_order")

      co_pred_names = collection_object_predicate_names
      ce_pred_names = collecting_event_predicate_names

      # Build aggregate statements for each CO predicate.
      # Use MAX with FILTER which is more efficient than MAX(CASE...).
      # Sanitize values by replacing newlines and tabs with spaces (matching
      # Utilities::Strings.sanitize_for_csv behavior).
      co_case_statements = co_pred_names.map do |cvt_id, pred_name|
        # Quote the column name to handle special characters.
        quoted_name = conn.quote_column_name(pred_name)
        "MAX(pg_temp.sanitize_csv(co_da.value)) FILTER (WHERE co_da.controlled_vocabulary_term_id = #{cvt_id}) AS #{quoted_name}"
      end

      # Build aggregate statements for each CE predicate.
      # Sanitize values by replacing newlines and tabs with spaces.
      ce_case_statements = ce_pred_names.map do |cvt_id, pred_name|
        quoted_name = conn.quote_column_name(pred_name)
        "MAX(pg_temp.sanitize_csv(ce_da.value)) FILTER (WHERE ce_da.controlled_vocabulary_term_id = #{cvt_id}) AS #{quoted_name}"
      end

      all_case_statements = (co_case_statements + ce_case_statements).join(",\n      ")

      # If no predicates, create table with just co_id
      if all_case_statements.empty?
        all_case_statements = "NULL AS placeholder"
      end

      # Build the query
      # Use collection_objects CTE to ensure all COs are included (even those without DAs)
      sql = <<-SQL
        CREATE TEMP TABLE temp_predicate_pivot AS
        SELECT
          co.id as co_id
          #{all_case_statements.empty? ? '' : ',' + all_case_statements}
        FROM (#{collection_objects.unscope(:order).select(:id, :collecting_event_id).to_sql}) co
      SQL

      # Add CO data attributes join if needed
      if co_pred_names.any?
        sql += <<-SQL
          LEFT JOIN data_attributes co_da ON co_da.attribute_subject_id = co.id
            AND co_da.attribute_subject_type = 'CollectionObject'
            AND co_da.type = 'InternalAttribute'
            AND co_da.controlled_vocabulary_term_id IN (#{co_pred_names.keys.join(',')})
        SQL
      end

      # Add CE data attributes join if needed
      if ce_pred_names.any?
        sql += <<-SQL
          LEFT JOIN collecting_events ce ON ce.id = co.collecting_event_id
          LEFT JOIN data_attributes ce_da ON ce_da.attribute_subject_id = ce.id
            AND ce_da.attribute_subject_type = 'CollectingEvent'
            AND ce_da.type = 'InternalAttribute'
            AND ce_da.controlled_vocabulary_term_id IN (#{ce_pred_names.keys.join(',')})
        SQL
      end

      sql += <<-SQL
        GROUP BY co.id
      SQL

      conn.execute(sql)

      Rails.logger.debug 'dwca_export: pivoted predicate temp table created'

      # Create ordering table based on dwc_occurrences.id order. This ensures we
      # can join and order correctly without loading all IDs into Ruby.
      order_sql = <<-SQL
        CREATE TEMP TABLE temp_co_order AS
        SELECT
          dwc_occurrences.dwc_occurrence_object_id as co_id,
          ROW_NUMBER() OVER (ORDER BY dwc_occurrences.id) as ord
        FROM (#{core_scope.unscope(:order).to_sql}) dwc_occurrences
        WHERE dwc_occurrences.dwc_occurrence_object_type = 'CollectionObject'
      SQL

      conn.execute(order_sql)

      Rails.logger.debug 'dwca_export: co order temp table created'
    end

    def predicate_data
      return @predicate_data if @predicate_data

      # Create temporary function for sanitizing CSV values
      create_csv_sanitize_function

      # Get all possible predicates from configuration
      all_possible_predicates

      if all_possible_predicates.empty?
        @predicate_data = Tempfile.new('predicate_data.tsv')
        return @predicate_data
      end

      # Create pivoted temp table with one row per CO, one column per predicate
      create_pivoted_predicate_table

      # Now query the temp table to find which columns actually have data
      used_preds = predicates_with_data

      if used_preds.empty?
        @predicate_data = Tempfile.new('predicate_data.tsv')
        return @predicate_data
      end

      Rails.logger.debug 'dwca_export: predicate_data reading from temp table'

      conn = ActiveRecord::Base.connection

      # Build column list for only the predicates that have data
      column_list = used_preds.map { |pred| conn.quote_column_name(pred) }.join(', ')

      # Use PostgreSQL's COPY TO to generate TSV directly.
      # Join with ordering table and let PostgreSQL handle the sorting - this
      # avoids loading all IDs into Ruby memory.
      copy_sql = <<-SQL
        COPY (
          SELECT #{column_list}
          FROM temp_co_order
          LEFT JOIN temp_predicate_pivot ON temp_predicate_pivot.co_id = temp_co_order.co_id
          ORDER BY temp_co_order.ord
        ) TO STDOUT WITH (FORMAT CSV, DELIMITER E'\\t', HEADER, NULL '')
      SQL

      # Stream output directly from PostgreSQL to file
      @predicate_data = Tempfile.new('predicate_data.tsv')
      conn.raw_connection.copy_data(copy_sql) do
        while row = conn.raw_connection.get_copy_data
          @predicate_data.write(row.force_encoding(Encoding::UTF_8))
        end
      end

      @predicate_data.flush
      @predicate_data.rewind

      Rails.logger.debug 'dwca_export: predicate_data written'

      @predicate_data
    end

    # @return Tempfile
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

    # This is a stub, and only half-heartedly done. You should be using IPT for the time being.
    # @return [Tempfile]
    #   metadata about this dataset
    # See also
    #    https://github.com/gbif/ipt/wiki/resourceMetadata
    #    https://github.com/gbif/ipt/wiki/resourceMetadata#exemplar-datasets
    #
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

    # rubocop:enable Metrics/MethodLength

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
      return nil if biological_associations_extension.nil?
      @biological_associations_resource_relationship_tmp = Tempfile.new('biological_resource_relationship.xml')

      if no_records?
        @biological_associations_resource_relationship_tmp.write("\n")
      else
        Export::CSV::Dwc::Extension::BiologicalAssociations.csv(
          biological_associations_extension,
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
      @media_tmp = Tempfile.new('media.xml')

      if no_records?
        @media_tmp.write("\n")
      else
        # Write directly to @media_tmp to avoid loading entire dataset into memory
        media_extension_optimized(@media_tmp)
      end

      @media_tmp.flush
      @media_tmp.rewind
      @media_tmp
    end

    # SQL fragment: Copyright label "© {year} {authors}"
    # Uses pg_temp.authorship_sentence to format author names grammatically
    # Expects attribution data from temp_*_attributions table
    def copyright_label_sql_from_temp(attr_table_alias = 'attr')
      <<-SQL
        CASE
          WHEN #{attr_table_alias}.copyright_year IS NOT NULL OR #{attr_table_alias}.copyright_holder_names_array IS NOT NULL THEN
            '©' ||
            CASE
              WHEN #{attr_table_alias}.copyright_year IS NOT NULL AND #{attr_table_alias}.copyright_holder_names_array IS NOT NULL
                THEN #{attr_table_alias}.copyright_year::text || ' ' || pg_temp.authorship_sentence(#{attr_table_alias}.copyright_holder_names_array)
              WHEN #{attr_table_alias}.copyright_year IS NOT NULL
                THEN #{attr_table_alias}.copyright_year::text
              ELSE pg_temp.authorship_sentence(#{attr_table_alias}.copyright_holder_names_array)
            END
          ELSE NULL
        END
      SQL
    end

    # Collect all image and sound IDs that need to be exported
    # Create a temporary table containing all scoped collection_object and field_occurrence IDs
    # This is used to filter media records to only include those associated with exported occurrences
    def create_scoped_occurrence_temp_table
      conn = ActiveRecord::Base.connection

      conn.execute("DROP TABLE IF EXISTS temp_scoped_occurrences")

      sql = <<-SQL
        CREATE TEMP TABLE temp_scoped_occurrences (
          occurrence_type text,
          occurrence_id integer,
          PRIMARY KEY (occurrence_type, occurrence_id)
        )
      SQL
      conn.execute(sql)

      # Insert scoped collection objects
      if @media_extension[:collection_objects]
        conn.execute(<<-SQL)
          INSERT INTO temp_scoped_occurrences (occurrence_type, occurrence_id)
          SELECT 'CollectionObject', id
          FROM (#{@media_extension[:collection_objects]}) AS co
        SQL
      end

      # Insert scoped field occurrences
      if @media_extension[:field_occurrences]
        conn.execute(<<-SQL)
          INSERT INTO temp_scoped_occurrences (occurrence_type, occurrence_id)
          SELECT 'FieldOccurrence', id
          FROM (#{@media_extension[:field_occurrences]}) AS fo
        SQL
      end

      Rails.logger.debug 'dwca_export: scoped occurrence temp table created'
    end

    # @return [Hash] { image_ids: Array<Integer>, sound_ids: Array<Integer> }
    def collect_media_ids
      image_ids = collect_media_image_ids
      sound_ids = collect_media_sound_ids

      Rails.logger.debug "dwca_export: found #{image_ids.count} images and #{sound_ids.count} sounds to export"

      { image_ids: image_ids, sound_ids: sound_ids }
    end

    def collect_media_image_ids
      conn = ActiveRecord::Base.connection
      image_ids = []

      if @media_extension[:collection_objects]
        co_sql = @media_extension[:collection_objects]

        # Get direct images (via depictions)
        image_ids += conn.execute(<<-SQL).values.flatten
          SELECT DISTINCT images.id
          FROM (#{co_sql}) AS co
          INNER JOIN depictions ON depictions.depiction_object_id = co.id
            AND depictions.depiction_object_type = 'CollectionObject'
          INNER JOIN images ON images.id = depictions.image_id
        SQL

        # Get images via observations
        image_ids += conn.execute(<<-SQL).values.flatten
          SELECT DISTINCT images.id
          FROM (#{co_sql}) AS co
          INNER JOIN observations obs ON obs.observation_object_id = co.id
            AND obs.observation_object_type = 'CollectionObject'
          INNER JOIN depictions ON depictions.depiction_object_id = obs.id
            AND depictions.depiction_object_type = 'Observation'
          INNER JOIN images ON images.id = depictions.image_id
        SQL
      end

      if @media_extension[:field_occurrences]
        fo_sql = @media_extension[:field_occurrences]

        # Get direct images (via depictions)
        image_ids += conn.execute(<<-SQL).values.flatten
          SELECT DISTINCT images.id
          FROM (#{fo_sql}) AS fo
          INNER JOIN depictions ON depictions.depiction_object_id = fo.id
            AND depictions.depiction_object_type = 'FieldOccurrence'
          INNER JOIN images ON images.id = depictions.image_id
        SQL

        # Get images via observations
        image_ids += conn.execute(<<-SQL).values.flatten
          SELECT DISTINCT images.id
          FROM (#{fo_sql}) AS fo
          INNER JOIN observations obs ON obs.observation_object_id = fo.id
            AND obs.observation_object_type = 'FieldOccurrence'
          INNER JOIN depictions ON depictions.depiction_object_id = obs.id
            AND depictions.depiction_object_type = 'Observation'
          INNER JOIN images ON images.id = depictions.image_id
        SQL
      end

      image_ids.uniq
    end

    def collect_media_sound_ids
      conn = ActiveRecord::Base.connection
      sound_ids = []

      if @media_extension[:collection_objects]
        co_sql = @media_extension[:collection_objects]

        # Get direct sounds (via conveyances)
        sound_ids += conn.execute(<<-SQL).values.flatten
          SELECT DISTINCT sounds.id
          FROM (#{co_sql}) AS co
          INNER JOIN conveyances ON conveyances.conveyance_object_id = co.id
            AND conveyances.conveyance_object_type = 'CollectionObject'
          INNER JOIN sounds ON sounds.id = conveyances.sound_id
        SQL
      end

      if @media_extension[:field_occurrences]
        fo_sql = @media_extension[:field_occurrences]

        # Get direct sounds (via conveyances)
        sound_ids += conn.execute(<<-SQL).values.flatten
          SELECT DISTINCT sounds.id
          FROM (#{fo_sql}) AS fo
          INNER JOIN conveyances ON conveyances.conveyance_object_id = fo.id
            AND conveyances.conveyance_object_type = 'FieldOccurrence'
          INNER JOIN sounds ON sounds.id = conveyances.sound_id
        SQL
      end

      sound_ids.uniq
    end

    def create_image_temp_tables
      # Create temp table with image IDs to avoid massive IN clauses (128k+ IDs).
      Rails.logger.debug 'dwca_export: creating temp tables for API image links'

      conn = ActiveRecord::Base.connection

      conn.execute("DROP TABLE IF EXISTS temp_media_image_links")
      conn.execute(<<-SQL)
        CREATE TEMP TABLE temp_media_image_links (
          image_id integer PRIMARY KEY,
          access_uri text,
          further_information_url text
        )
      SQL

      # Only needed to create temp_media_image_links.
      conn.execute("DROP TABLE IF EXISTS temp_media_image_ids")
      conn.execute("CREATE TEMP TABLE temp_media_image_ids (image_id integer PRIMARY KEY)")
    end

    # Create temporary tables with pre-computed API links for images and sounds
    # This must use Ruby because API link generation uses the URL shortener
    # @param image_ids [Array<Integer>]
    # @param sound_ids [Array<Integer>]
    def create_media_api_link_tables(image_ids, sound_ids)
      populate_temp_image_api_links_table(image_ids)
      populate_temp_sound_api_links_table(sound_ids)
    end

    def populate_temp_image_api_links_table(image_ids)
      return if image_ids.empty?

      create_image_temp_tables

      raw = ActiveRecord::Base.connection.raw_connection

      # Populate temp_media_image_ids.
      ActiveRecord::Base.connection.raw_connection.copy_data("COPY temp_media_image_ids (image_id) FROM STDIN") do
        image_ids.each do |id|
          raw.put_copy_data("#{id}\n")
        end
      end

      populate_temp_image_links_table
    end

    def populate_temp_image_links_table
      conn = ActiveRecord::Base.connection

      image_file_prefix_sql = conn.quote(Shared::Api.image_file_url_prefix)
      image_metadata_prefix_sql =
        conn.quote(Shared::Api.image_metadata_url_prefix)

      # Relation includes short urls when they exist.
      image_relation = Image
        .joins("JOIN temp_media_image_ids tmp ON tmp.image_id = images.id")
        .joins(:project)
        .joins(<<~SQL)
          LEFT JOIN shortened_urls su_access
            ON su_access.url = #{image_file_prefix_sql}
              || images.image_file_fingerprint
              || '?project_token='
              || projects.api_access_token
        SQL
        .joins(<<~SQL)
          LEFT JOIN shortened_urls su_metadata
            ON su_metadata.url = #{image_metadata_prefix_sql}
              || images.id
              || '?project_token='
              || projects.api_access_token
        SQL
        .where.not(projects: { api_access_token: nil })
        .select(
          'images.id AS image_id',
          'images.image_file_fingerprint',
          'projects.api_access_token AS token',
          'su_access.unique_key AS access_short_key',
          'su_metadata.unique_key AS metadata_short_key'
        )

      image_relation.in_batches(of: 10_000) do |batch_scope|
        rows = conn.select_all(batch_scope.to_sql) # each row is a hash
        links_data = []

        rows.each do |row|
          begin
            image_id = row['image_id'].to_i
            fingerprint = row['image_file_fingerprint']
            token = row['token']

            access_uri =
              if row['access_short_key']
                Shared::Api.short_url_from_key(row['access_short_key'])
              else
                Shared::Api.shorten_url(
                  Shared::Api.image_file_long_url(fingerprint, token)
                )
              end

            further_info_url =
              if row['metadata_short_key']
                Shared::Api.short_url_from_key(row['metadata_short_key'])
              else
                Shared::Api.shorten_url(
                  Shared::Api.image_metadata_long_url(image_id, token)
                )
              end

            links_data << {
              image_id: image_id,
              access_uri: access_uri,
              further_information_url: further_info_url
            }
          rescue => e
            Rails.logger.warn "dwca_export: skipping image #{row['image_id']} - #{e.message}"
          end
        end

        next if links_data.empty?

        values_sql = links_data.map { |ldata|
          "(#{ldata[:image_id]}, " \
            "#{conn.quote(ldata[:access_uri])}, " \
            "#{conn.quote(ldata[:further_information_url])})"
        }.join(', ')

        conn.execute(<<~SQL)
          INSERT INTO temp_media_image_links
            (image_id, access_uri, further_information_url)
          VALUES
            #{values_sql}
        SQL
      end

      Rails.logger.debug 'dwca_export: temp table created with API image links'
    end

    def populate_temp_sound_api_links_table(sound_ids)
      return if sound_ids.empty?

      conn = ActiveRecord::Base.connection

      Rails.logger.debug 'dwca_export: creating temp table for API sound IDs'

      # Drop from previous runs if present
      conn.execute("DROP TABLE IF EXISTS temp_media_sound_links")
      conn.execute(<<~SQL)
        CREATE TEMP TABLE temp_media_sound_links (
          sound_id integer PRIMARY KEY,
          access_uri text,
          further_information_url text
        )
      SQL

      conn.execute("DROP TABLE IF EXISTS temp_media_sound_ids")
      conn.execute("CREATE TEMP TABLE temp_media_sound_ids (sound_id integer PRIMARY KEY)")

      # Insert IDs into temp table in batches to avoid huge VALUES lists
      sound_ids.each_slice(10_000) do |batch|
        values = batch.map { |id| "(#{id})" }.join(', ')
        conn.execute("INSERT INTO temp_media_sound_ids (sound_id) VALUES #{values}")
      end

      # Build a relation using the temp IDs, so we don’t end up with a massive
      # IN ().
      Sound
          .joins("JOIN temp_media_sound_ids tmp ON tmp.sound_id = sounds.id")
          .includes(:sound_file_attachment, :project)
          .in_batches(of: 10_000) do |batch_scope|
        batch_sounds = batch_scope.to_a
        links_data   = []

        batch_sounds.each do |snd|
          begin
            token = snd.project&.api_access_token
            if token.nil?
              Rails.logger.warn "dwca_export: skipping sound #{snd.id} - no project token"
              next
            end

            # Must use full AR objects for these helpers
            access_uri = Shared::Api.sound_link(snd)
            further_info_url = Shared::Api.sound_metadata_link(
              snd,
              raise_on_no_token: true,
              token: token
            )

            links_data << {
              sound_id: snd.id,
              access_uri: access_uri,
              further_information_url: further_info_url
            }
          rescue => e
            Rails.logger.warn "dwca_export: skipping sound #{snd.id} - #{e.message}"
          end
        end

        next if links_data.empty?

        values_sql = links_data.map { |row|
          "(#{row[:sound_id]}, " \
            "#{conn.quote(row[:access_uri])}, " \
            "#{conn.quote(row[:further_information_url])})"
        }.join(', ')

        conn.execute(<<~SQL)
          INSERT INTO temp_media_sound_links
            (sound_id, access_uri, further_information_url)
          VALUES
            #{values_sql}
        SQL
      end

      Rails.logger.debug 'dwca_export: temp table created with API sound links'
    end

    # SQL fragment: Media identifier with UUID/URI fallback
    # Delegates to the class method to ensure consistency with Ruby implementation
    # @param media_class [Class] Media class (Image or Sound)
    # @param media_table_alias [String] SQL table alias for the media table
    # @return [String] SQL fragment for media identifier (sanitized)
    def media_identifier_sql(media_class, media_table_alias)
      identifier_expr = media_class.dwc_media_identifier_sql(table_alias: media_table_alias)
      "pg_temp.sanitize_csv(#{identifier_expr})"
    end

    # SQL fragment: Media identifier JOINs for UUID and URI
    # Provides LEFT JOINs to the identifiers table for UUID and URI lookups
    # @param media_class [Class] Media class (Image or Sound)
    # @param table_alias [String] SQL table alias for the media table
    # @return [String] SQL JOIN clauses for UUID and URI identifiers
    def media_identifier_joins_sql(media_class, table_alias)
      media_type = media_class.name
      <<~SQL.squish
        LEFT JOIN identifiers uuid_id ON uuid_id.identifier_object_id = #{table_alias}.id
                                      AND uuid_id.identifier_object_type = '#{media_type}'
                                      AND uuid_id.type LIKE  'Identifier::Global::Uuid%'
        LEFT JOIN identifiers uri_id ON uri_id.identifier_object_id = #{table_alias}.id
                                     AND uri_id.identifier_object_type = '#{media_type}'
                                     AND uri_id.type LIKE 'Identifier::Global::Uri%'
      SQL
    end

    # SQL fragment: Image occurrence resolution JOINs
    # Resolves images to dwc_occurrences via depictions -> collection_objects/field_occurrences
    # Includes filtering to only scoped occurrences
    # @param image_alias [String] SQL table alias for images table
    # @return [String] SQL JOIN clauses for resolving image to occurrence
    def image_occurrence_resolution_joins_sql(image_alias: 'img')
      <<~SQL
        -- Join to get coreid (occurrenceID) via depiction -> collection_object/field_occurrence -> dwc_occurrence
        -- IMPORTANT: Only include media for occurrences that are actually in the export scope
        LEFT JOIN depictions dep ON dep.image_id = #{image_alias}.id
        LEFT JOIN collection_objects co ON co.id = dep.depiction_object_id AND dep.depiction_object_type = 'CollectionObject'
        LEFT JOIN field_occurrences fo ON fo.id = dep.depiction_object_id AND dep.depiction_object_type = 'FieldOccurrence'
        LEFT JOIN observations obs ON obs.id = dep.depiction_object_id AND dep.depiction_object_type = 'Observation'
        LEFT JOIN collection_objects co_obs ON co_obs.id = obs.observation_object_id AND obs.observation_object_type = 'CollectionObject'
        LEFT JOIN field_occurrences fo_obs ON fo_obs.id = obs.observation_object_id AND obs.observation_object_type = 'FieldOccurrence'

        -- Filter to only scoped occurrences
        LEFT JOIN temp_scoped_occurrences scope_co ON scope_co.occurrence_id = co.id AND scope_co.occurrence_type = 'CollectionObject'
        LEFT JOIN temp_scoped_occurrences scope_fo ON scope_fo.occurrence_id = fo.id AND scope_fo.occurrence_type = 'FieldOccurrence'
        LEFT JOIN temp_scoped_occurrences scope_co_obs ON scope_co_obs.occurrence_id = co_obs.id AND scope_co_obs.occurrence_type = 'CollectionObject'
        LEFT JOIN temp_scoped_occurrences scope_fo_obs ON scope_fo_obs.occurrence_id = fo_obs.id AND scope_fo_obs.occurrence_type = 'FieldOccurrence'

        LEFT JOIN dwc_occurrences dwc ON (dwc.dwc_occurrence_object_id = co.id AND dwc.dwc_occurrence_object_type = 'CollectionObject' AND scope_co.occurrence_id IS NOT NULL)
                                      OR (dwc.dwc_occurrence_object_id = fo.id AND dwc.dwc_occurrence_object_type = 'FieldOccurrence' AND scope_fo.occurrence_id IS NOT NULL)
                                      OR (dwc.dwc_occurrence_object_id = co_obs.id AND dwc.dwc_occurrence_object_type = 'CollectionObject' AND scope_co_obs.occurrence_id IS NOT NULL)
                                      OR (dwc.dwc_occurrence_object_id = fo_obs.id AND dwc.dwc_occurrence_object_type = 'FieldOccurrence' AND scope_fo_obs.occurrence_id IS NOT NULL)
      SQL
    end

    # SQL fragment: Sound occurrence resolution JOINs
    # Resolves sounds to dwc_occurrences via conveyances -> collection_objects/field_occurrences
    # Includes filtering to only scoped occurrences
    # @param sound_alias [String] SQL table alias for sounds table
    # @return [String] SQL JOIN clauses for resolving sound to occurrence
    def sound_occurrence_resolution_joins_sql(sound_alias: 'snd')
      <<~SQL
        -- Join to get coreid (occurrenceID) via conveyance -> collection_object/field_occurrence -> dwc_occurrence
        -- IMPORTANT: Only include media for occurrences that are actually in the export scope
        LEFT JOIN conveyances conv ON conv.sound_id = #{sound_alias}.id
        LEFT JOIN collection_objects co ON co.id = conv.conveyance_object_id AND conv.conveyance_object_type = 'CollectionObject'
        LEFT JOIN field_occurrences fo ON fo.id = conv.conveyance_object_id AND conv.conveyance_object_type = 'FieldOccurrence'

        -- Filter to only scoped occurrences
        LEFT JOIN temp_scoped_occurrences scope_co ON scope_co.occurrence_id = co.id AND scope_co.occurrence_type = 'CollectionObject'
        LEFT JOIN temp_scoped_occurrences scope_fo ON scope_fo.occurrence_id = fo.id AND scope_fo.occurrence_type = 'FieldOccurrence'

        LEFT JOIN dwc_occurrences dwc ON (dwc.dwc_occurrence_object_id = co.id AND dwc.dwc_occurrence_object_type = 'CollectionObject' AND scope_co.occurrence_id IS NOT NULL)
                                      OR (dwc.dwc_occurrence_object_id = fo.id AND dwc.dwc_occurrence_object_type = 'FieldOccurrence' AND scope_fo.occurrence_id IS NOT NULL)
      SQL
    end

    # SQL fragment: Associated specimen reference URL
    # Handles collection objects, field occurrences, and their observations
    # @param include_observations [Boolean] whether to include observation table aliases (co_obs, fo_obs)
    # @return [String] SQL CASE statement for building specimen reference URLs
    def associated_specimen_reference_sql(include_observations: true)
      co_base = Shared::Api.api_base_path(CollectionObject)
      fo_base = Shared::Api.api_base_path(FieldOccurrence)

      base_cases = <<~SQL.strip
        CASE
          WHEN co.id IS NOT NULL THEN '#{co_base}/' || co.id
          WHEN fo.id IS NOT NULL THEN '#{fo_base}/' || fo.id
      SQL

      observation_cases = if include_observations
        <<~SQL

          WHEN co_obs.id IS NOT NULL THEN '#{co_base}/' || co_obs.id
          WHEN fo_obs.id IS NOT NULL THEN '#{fo_base}/' || fo_obs.id
        SQL
      else
        "\n"
      end

      <<~SQL.strip
        #{base_cases}#{observation_cases}          ELSE NULL
        END
      SQL
    end

    # Exports image media records to the output file using PostgreSQL COPY TO
    # Streams data directly to avoid loading entire dataset into memory
    def export_images_to_file(image_ids, output_file)
      return if image_ids.empty?

      conn = ActiveRecord::Base.connection
      copyright_label = copyright_label_sql_from_temp('attr')

      image_copy_sql = <<-SQL
        COPY (
          SELECT
            pg_temp.sanitize_csv(dwc.\"occurrenceID\") AS coreid,
            #{media_identifier_sql(Image, 'img')} AS identifier,
            'Image' AS \"dc:type\",
            img.id AS \"providerManagedID\",
            pg_temp.sanitize_csv(attr.license_url) AS \"dc:rights\",
            pg_temp.sanitize_csv(attr.license_url) AS \"dcterms:rights\",
            pg_temp.sanitize_csv(attr.owner_names) AS \"Owner\",
            NULL AS \"UsageTerms\",
            pg_temp.sanitize_csv(#{copyright_label}) AS \"Credit\",
            pg_temp.sanitize_csv(attr.creator_names) AS \"dc:creator\",
            pg_temp.sanitize_csv(attr.creator_identifiers) AS \"dcterms:creator\",
            pg_temp.sanitize_csv(dep.figure_label) AS description,
            pg_temp.sanitize_csv(dep.caption) AS caption,
            -- Compute associatedSpecimenReference directly from collection object ID for this row
            #{associated_specimen_reference_sql} AS \"associatedSpecimenReference\",
            NULL AS \"associatedObservationReference\",
            links.access_uri AS \"accessURI\",
            img.image_file_content_type AS \"dc:format\",
            links.further_information_url AS \"furtherInformationURL\",
            img.width AS \"PixelXDimension\",
            img.height AS \"PixelYDimension\"
          FROM images img

          #{image_occurrence_resolution_joins_sql(image_alias: 'img')}

          -- Join temp table for API links
          LEFT JOIN temp_media_image_links links ON links.image_id = img.id

          -- Join pre-computed attribution data from temp table
          LEFT JOIN temp_image_attributions attr ON attr.image_id = img.id

          -- Join identifiers for UUID and URI
          #{media_identifier_joins_sql(Image, 'img')}

          -- Filter to only images in the collected set (using temp table to avoid huge IN clause)
          INNER JOIN temp_media_image_links img_filter ON img_filter.image_id = img.id

          WHERE dwc.\"occurrenceID\" IS NOT NULL  -- Only include media with valid occurrence links
          ORDER BY img.id
        ) TO STDOUT WITH (FORMAT CSV, DELIMITER E'\\t', NULL '')
      SQL

      conn.raw_connection.copy_data(image_copy_sql) do
        while row = conn.raw_connection.get_copy_data
          output_file.write(row.force_encoding(Encoding::UTF_8))
        end
      end
    end

    # Exports sound media records to the output file using PostgreSQL COPY TO
    # Streams data directly to avoid loading entire dataset into memory
    def export_sounds_to_file(sound_ids, output_file)
      return if sound_ids.empty?

      conn = ActiveRecord::Base.connection
      copyright_label = copyright_label_sql_from_temp('attr')

      sound_copy_sql = <<-SQL
        COPY (
          SELECT
            pg_temp.sanitize_csv(dwc.\"occurrenceID\") AS coreid,
            #{media_identifier_sql(Sound, 'snd')} AS identifier,
            'Sound' AS \"dc:type\",
            snd.id AS \"providerManagedID\",
            pg_temp.sanitize_csv(attr.license_url) AS \"dc:rights\",
            pg_temp.sanitize_csv(attr.license_url) AS \"dcterms:rights\",
            pg_temp.sanitize_csv(attr.owner_names) AS \"Owner\",
            NULL AS \"UsageTerms\",
            pg_temp.sanitize_csv(#{copyright_label}) AS \"Credit\",
            pg_temp.sanitize_csv(attr.creator_names) AS \"dc:creator\",
            pg_temp.sanitize_csv(attr.creator_identifiers) AS \"dcterms:creator\",
            pg_temp.sanitize_csv(snd.name) AS description,
            NULL AS caption,
            -- Compute associatedSpecimenReference directly from collection object ID for this row
            #{associated_specimen_reference_sql(include_observations: false)} AS \"associatedSpecimenReference\",
            NULL AS \"associatedObservationReference\",
            links.access_uri AS \"accessURI\",
            asb.content_type AS \"dc:format\",
            links.further_information_url AS \"furtherInformationURL\",
            NULL AS \"PixelXDimension\",
            NULL AS \"PixelYDimension\"
          FROM sounds snd
          LEFT JOIN active_storage_attachments asa ON asa.record_id = snd.id
                                                   AND asa.record_type = 'Sound'
                                                   AND asa.name = 'sound_file'
          LEFT JOIN active_storage_blobs asb ON asb.id = asa.blob_id

          #{sound_occurrence_resolution_joins_sql(sound_alias: 'snd')}

          -- Join temp table for API links
          LEFT JOIN temp_media_sound_links links ON links.sound_id = snd.id

          -- Join pre-computed attribution data from temp table
          LEFT JOIN temp_sound_attributions attr ON attr.sound_id = snd.id

          -- Join identifiers for UUID and URI
          #{media_identifier_joins_sql(Sound, 'snd')}

          -- Filter to only sounds in the collected set (using temp table to avoid huge IN clause)
          INNER JOIN temp_media_sound_links snd_filter ON snd_filter.sound_id = snd.id

          WHERE dwc.\"occurrenceID\" IS NOT NULL  -- Only include media with valid occurrence links
          ORDER BY snd.id
        ) TO STDOUT WITH (FORMAT CSV, DELIMITER E'\\t', NULL '')
      SQL

      conn.raw_connection.copy_data(sound_copy_sql) do
        while row = conn.raw_connection.get_copy_data
          output_file.write(row.force_encoding(Encoding::UTF_8))
        end
      end
    end

    # Creates temporary tables with pre-aggregated attribution data for images and sounds
    # This avoids expensive LATERAL joins in the main export query
    def create_media_attribution_temp_tables(image_ids, sound_ids)
      conn = ActiveRecord::Base.connection

      # Create temp table for image attributions
      unless image_ids.empty?
        # Get the license SQL that converts license keys to URLs
        license_sql = Image.dwc_media_license_sql(table_alias: 'img')

        conn.execute("DROP TABLE IF EXISTS temp_image_attributions")
        conn.execute(<<~SQL)
          CREATE TEMP TABLE temp_image_attributions AS
          SELECT
            img.id AS image_id,
            #{license_sql} AS license_url,
            attributions.copyright_year,
            owners.names AS owner_names,
            creators.names AS creator_names,
            creator_ids.ids AS creator_identifiers,
            copyright_holders.names_array AS copyright_holder_names_array
          FROM images img
          LEFT JOIN attributions ON attributions.attribution_object_id = img.id
            AND attributions.attribution_object_type = 'Image'
          #{Image.dwc_media_owner_sql(table_alias: 'img')}
          #{Image.dwc_media_creator_sql(table_alias: 'img')}
          #{Image.dwc_media_creator_identifiers_sql(table_alias: 'img')}
          #{Image.dwc_media_copyright_holders_sql(table_alias: 'img')}
          WHERE img.id IN (#{image_ids.join(',')})
        SQL
        conn.execute("CREATE INDEX idx_temp_image_attr ON temp_image_attributions(image_id)")
      end

      # Create temp table for sound attributions
      unless sound_ids.empty?
        # Get the license SQL that converts license keys to URLs
        license_sql = Sound.dwc_media_license_sql(table_alias: 'snd')

        conn.execute("DROP TABLE IF EXISTS temp_sound_attributions")
        conn.execute(<<~SQL)
          CREATE TEMP TABLE temp_sound_attributions AS
          SELECT
            snd.id AS sound_id,
            #{license_sql} AS license_url,
            attributions.copyright_year,
            owners.names AS owner_names,
            creators.names AS creator_names,
            creator_ids.ids AS creator_identifiers,
            copyright_holders.names_array AS copyright_holder_names_array
          FROM sounds snd
          LEFT JOIN attributions ON attributions.attribution_object_id = snd.id
            AND attributions.attribution_object_type = 'Sound'
          #{Sound.dwc_media_owner_sql(table_alias: 'snd')}
          #{Sound.dwc_media_creator_sql(table_alias: 'snd')}
          #{Sound.dwc_media_creator_identifiers_sql(table_alias: 'snd')}
          #{Sound.dwc_media_copyright_holders_sql(table_alias: 'snd')}
          WHERE snd.id IN (#{sound_ids.join(',')})
        SQL
        conn.execute("CREATE INDEX idx_temp_sound_attr ON temp_sound_attributions(sound_id)")
      end
    end

    # Cleans up temporary tables created for media export
    def cleanup_media_temp_tables
      conn = ActiveRecord::Base.connection
      conn.execute("DROP TABLE IF EXISTS temp_scoped_occurrences")
      conn.execute("DROP TABLE IF EXISTS temp_media_image_links")
      conn.execute("DROP TABLE IF EXISTS temp_media_sound_links")
      conn.execute("DROP TABLE IF EXISTS temp_image_attributions")
      conn.execute("DROP TABLE IF EXISTS temp_sound_attributions")
    end

    # Optimized media extension export using PostgreSQL COPY TO
    # Streams directly to output_file to avoid loading entire dataset into memory
    # ~10x faster than the original Ruby iteration approach
    def media_extension_optimized(output_file)
      Rails.logger.debug 'dwca_export: media_extension_optimized start'

      # Create temporary functions for sanitizing CSV values and formatting author lists
      create_csv_sanitize_function
      create_authorship_sentence_function

      # Step 1: Collect all media IDs from collection objects and field occurrences
      media_ids = collect_media_ids
      image_ids = media_ids[:image_ids]
      sound_ids = media_ids[:sound_ids]

      # Early return if no media to export
      if image_ids.empty? && sound_ids.empty?
        output_file.write(Export::CSV::Dwc::Extension::Media::HEADERS.join("\t") + "\n")
        return
      end

      # Step 2: Create temp table with scoped occurrence IDs to prevent orphaned media records
      create_scoped_occurrence_temp_table

      # Step 3: Pre-compute attribution data to avoid expensive LATERAL joins
      create_media_attribution_temp_tables(image_ids, sound_ids)

      # Step 4: Pre-compute API links using Ruby (required for URL shortener)
      create_media_api_link_tables(image_ids, sound_ids)

      # Step 4: Write header and stream media data to output file
      Rails.logger.debug 'dwca_export: executing COPY TO for media data'
      output_file.write(Export::CSV::Dwc::Extension::Media::HEADERS.join("\t") + "\n")

      export_images_to_file(image_ids, output_file)
      export_sounds_to_file(sound_ids, output_file)

      # Step 5: Cleanup temp tables
      cleanup_media_temp_tables

      Rails.logger.debug 'dwca_export: media data generated'
    end

    # @return [Array]
    #   use the temporarily written, and refined, CSV file to read off the existing headers
    #   so we can use them in writing meta.yml
    # non-standard DwC colums are handled elsewhere
    def meta_fields
      return [] if no_records?
      h = File.open(all_data, &:gets)&.strip&.split("\t")
      h&.shift # shift because the first column, id, will be specified by hand
      h || []
    end

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
            xml.id(index: 0) # Must be named id (?)
            meta_fields.each_with_index do |h,i|
              if h =~ /TW:/ # All TW headers have ':'
                xml.field(index: i+1, term: h)
              else
                xml.field(index: i+1, term: DwcOccurrence::DC_NAMESPACE + h)
              end
            end
          }

          # Resource relationship (biological associations)
          if !biological_associations_extension.nil?
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
          if !media_extension.nil?
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

      Zip::File.open(t.path, Zip::File::CREATE) do |zip|
        zip.add('data.tsv', all_data.path)

        zip.add('media.tsv', media_tmp.path) if media_extension
        zip.add('resource_relationships.tsv', biological_associations_resource_relationship_tmp.path) if biological_associations_extension

        zip.add('meta.xml', meta.path)
        zip.add('eml.xml', eml.path)
      end
      t
    end

    # @return [Tempfile]
    #   the zipfile
    def zipfile
      if @zipfile.nil?
        @zipfile = build_zip
      end
      @zipfile
    end

    # @return [String]
    # the name of zipfile
    def filename
      @filename ||= "dwc_occurrences_#{DateTime.now}.zip"
      @filename
    end

    # @return [True]
    #   close and delete all temporary files
    def cleanup

      Rails.logger.debug 'dwca_export: cleanup start'

      # Explicitly drop temp tables to avoid automatic cleanup delay
      if predicate_options_present?
        conn = ActiveRecord::Base.connection
        conn.execute("DROP TABLE IF EXISTS temp_predicate_pivot") rescue nil
        conn.execute("DROP TABLE IF EXISTS temp_co_order") rescue nil
        Rails.logger.debug 'dwca_export: temp tables dropped'
      end

      # Only cleanup files that were actually created (materialized)
      # This prevents lazy-loading during cleanup
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

      if biological_associations_extension && defined?(@biological_associations_resource_relationship_tmp) && @biological_associations_resource_relationship_tmp
        @biological_associations_resource_relationship_tmp.close
        @biological_associations_resource_relationship_tmp.unlink
      end

      if media_extension && defined?(@media_tmp) && @media_tmp
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
