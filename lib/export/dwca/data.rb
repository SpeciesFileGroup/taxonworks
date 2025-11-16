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

    # @return [Hash] of collection_objects: query_string, field_occurrences: query_string
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
    # ordered in the order they will be placed in the file
    # !!! Breaks if inter-mingled with asserted distributions !!!
    attr_accessor :collection_object_ids

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

      @biological_associations_extension = extension_scopes[:biological_associations] #! Hash with keys core_params, collection_objects_query
      @media_extension = extension_scopes[:media] #! Hash with keys collection_objects, field_occurrences

      @data_predicate_ids = { collection_object_predicate_id: [], collecting_event_predicate_id: [] }.merge(predicate_extensions)

      @eml_data = eml_data

      @taxonworks_extension_methods = taxonworks_extensions
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
      if q.kind_of?(String)
        ::BiologicalAssociation.from('(' + q + ') as biological_associations')
      elsif q.kind_of?(ActiveRecord::Relation)
        q
      else
        raise ArgumentError, 'Biological associations scope is not an SQL string or ActiveRecord::Relation'
      end
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

    # @return [CSV]
    #   the data as a CSV object
    def csv
      return @csv_content if @csv_content

      conn = ActiveRecord::Base.connection

      # Get all target columns (what we want to export)
      target_cols = ::DwcOccurrence.target_columns
      excluded = ::DwcOccurrence.excluded_columns

      # Remove excluded columns
      cols_to_export = target_cols - excluded

      # Determine which columns actually have data (trim_columns: true behavior)
      cols_with_data = columns_with_data(cols_to_export)

      # Apply column ordering if specified
      column_order = (::CollectionObject::DWC_OCCURRENCE_MAP.keys + ::CollectionObject::EXTENSION_FIELDS).map(&:to_s)
      ordered_cols = order_columns(cols_with_data, column_order)

      # Build SELECT list with proper column names and aliases
      # Sanitize string columns by replacing newlines and tabs with spaces (matching Utilities::Strings.sanitize_for_csv behavior)
      select_list = ordered_cols.map do |col|
        if col == 'id'
          # id is copied from occurrenceID (string), with sanitization
          "REGEXP_REPLACE(\"occurrenceID\", E'[\\n\\t]', ' ', 'g') AS \"id\""
        elsif col == 'dwcClass'
          # Header converter: dwcClass -> class, with sanitization
          "REGEXP_REPLACE(\"dwcClass\", E'[\\n\\t]', ' ', 'g') AS \"class\""
        elsif col == 'individualCount'
          # Integer column - no sanitization needed
          conn.quote_column_name(col)
        else
          # Sanitize all other columns (they're all varchar/text)
          "REGEXP_REPLACE(#{conn.quote_column_name(col)}, E'[\\n\\t]', ' ', 'g') AS #{conn.quote_column_name(col)}"
        end
      end.join(', ')

      # Build COPY TO query
      copy_sql = <<-SQL
        COPY (
          SELECT #{select_list}
          FROM (#{core_scope.to_sql}) AS dwc_data
        ) TO STDOUT WITH (FORMAT CSV, DELIMITER E'\\t', HEADER, NULL '')
      SQL

      # Execute COPY TO and collect output
      content = String.new(encoding: Encoding::UTF_8)
      conn.raw_connection.copy_data(copy_sql) do
        while row = conn.raw_connection.get_copy_data
          content << row.force_encoding(Encoding::UTF_8)
        end
      end

      Rails.logger.debug 'dwca_export: csv data generated'

      @csv_content = content
    end

    # Find which columns in the dwc_occurrence table have non-NULL, non-empty values
    # This implements the trim_columns: true behavior
    # Note: We check for non-empty AFTER sanitization (REGEXP_REPLACE)
    def columns_with_data(columns)
      return [] if columns.empty?

      conn = ActiveRecord::Base.connection

      # For each column, check if it has any non-NULL, non-empty values after sanitization
      # id and individualCount are non-string columns
      checks = columns.map.with_index do |col, idx|
        quoted = conn.quote_column_name(col)
        col_str = col.to_s
        if col_str == 'individualCount' || col_str == 'id'
          # Non-string columns - just check if not NULL
          "CASE WHEN COUNT(#{quoted}) > 0 THEN #{conn.quote(col_str)} ELSE NULL END AS check_#{idx}"
        else
          # String columns - check if any non-empty values after sanitization
          sanitized = "REGEXP_REPLACE(#{quoted}, E'[\\n\\t]', ' ', 'g')"
          "CASE WHEN COUNT(CASE WHEN #{sanitized} IS NOT NULL AND #{sanitized} != '' THEN 1 END) > 0 THEN #{conn.quote(col)} ELSE NULL END AS check_#{idx}"
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
      if no_records?
        content = "\n"
      else
        content = csv
      end

      @data = Tempfile.new('data.tsv')
      @data.write(content)
      @data.flush
      @data.rewind

      Rails.logger.debug 'dwca_export: data written'

      @data
    end

    # Get order of ids that matches core records so we can align with csv
    # @return Hash
    # zero! Like  {1=>0, 2=>1, 3=>2, 4=>3, 5=>4}
    def dwc_id_order
      @dwc_id_order ||= collection_object_ids.map.with_index.to_h
    end

    # TODO Breaks when AssertedDistribution is added
    def collection_object_ids
      @collection_object_ids ||= core_scope.where(dwc_occurrence_object_type: 'CollectionObject').pluck(:dwc_occurrence_object_id)
    end

    # TODO: return, or optimize to this when ::CollectionObject::EXTENSION_COMPUTED_FIELDS.size > 1
    # def extension_computed_fields_data(methods)
    #   d = []
    #   collection_objects.find_each do |object|
    #     methods.each_pair { |method, name| d  << [object.id, name, object.send(method)] }
    #   end
    #   d
    # end
    #
    # !! This will have to be reverted to above when > 1 EXTENSION field is present
    def extension_computed_fields_data(methods)
      return [] if methods.empty?

      a = "TW:Internal:otu_name".freeze

      # n = "COALESCE( otus.name, TRIM(CONCAT(cached, ' ', cached_author_year))) as otu_name"

      v = collection_objects.left_joins(otu: [:taxon_name])
        .select("collection_objects.id, otus.name as otu_name")
        .where(taxon_determinations: {position: '1'})
        .find_each(batch_size: 10000)
        .collect{|r| [r.id, a, r['otu_name'].presence] }
      v
    end

    # rubocop:disable Metrics/MethodLength

    def taxonworks_extension_data
      return @taxonworks_extension_data if @taxonworks_extension_data

      # hash of internal method name => csv header name
      methods = {}

      # hash of column_name => csv header name
      ce_fields = {}
      co_fields = {}
      dwco_fields = {}

      # Select valid methods, generate frozen name string ahead of time
      # add TW prefix to names
      taxonworks_extension_methods.map(&:to_sym).each do |sym|

        csv_header_name = ('TW:Internal:' + sym.name).freeze

        if (method = ::CollectionObject::EXTENSION_COMPUTED_FIELDS[sym])
          methods[method] = csv_header_name
        elsif (column_name = ::CollectionObject::EXTENSION_CE_FIELDS[sym])
          ce_fields[column_name] = csv_header_name
        elsif (column_name = ::CollectionObject::EXTENSION_CO_FIELDS[sym])
          co_fields[column_name] = csv_header_name
        elsif (column_name = ::CollectionObject::EXTENSION_DWC_OCCURRENCE_FIELDS[sym])
          dwco_fields[column_name] = csv_header_name
        end
      end

      used_extensions = methods.values + ce_fields.values + co_fields.values + dwco_fields.values

      # if no predicate data found, return empty file
      if used_extensions.empty?
        @taxonworks_extension_data = Tempfile.new('tw_extension_data.tsv')
        return @taxonworks_extension_data
      end

      extension_data = []

      extension_data += extension_computed_fields_data(methods)

      # extract to ensure consistent order
      co_columns = co_fields.keys
      co_csv_names = co_columns.map { |sym| co_fields[sym] }
      co_column_count = co_columns.size

      # TODO: we're replicating this to get ids as well in `collection_object_ids` so somewhat redundant
      # get all CO fields in one query, then split into triplets of [id, CSV column name, value]
      extension_data += collection_objects.pluck('collection_objects.id', *co_columns)
        .flat_map{ |id, *values| ([id] * co_column_count).zip(co_csv_names, values) }

      Rails.logger.debug 'dwca_export: post co extension read'

      ce_columns = ce_fields.keys
      ce_csv_names = ce_columns.map { |sym| ce_fields[sym] }
      ce_column_count = ce_columns.size

      # kludge to select correct column below
      ce_columns[ce_columns.index(:id)] = :collecting_event_id if ce_columns.index(:id)

      # no point using left outer join, no event means all data is nil
      extension_data += collection_objects.joins(:collecting_event)
        .pluck('collection_objects.id', *ce_columns)
        .flat_map{ |id, *values| ([id] * ce_column_count).zip(ce_csv_names, values) }

      Rails.logger.debug 'dwca_export: post ce extension read'

      dwco_columns = dwco_fields.keys
      dwco_csv_names = dwco_columns.map { |sym| dwco_fields[sym] }
      dwco_column_count = dwco_columns.size

      extension_data += core_scope
        .where(dwc_occurrence_object_type: 'CollectionObject')
        .pluck(:dwc_occurrence_object_id, *dwco_columns)
        .flat_map{ |dwc_occurrence_object_id, *values| ([dwc_occurrence_object_id] * dwco_column_count).zip(dwco_csv_names, values) }

      Rails.logger.debug 'dwca_export: post dwco extension read'

      # Create hash with key: co_id, value: [[extension_name, extension_value], ...]
      # pre-fill with empty values so we have the same number of rows as the main csv, even if some rows don't have
      # data attributes
      empty_hash = collection_object_ids.index_with { |_| []}

      data = extension_data.group_by(&:shift)

      data = empty_hash.merge(data)

      # write rows to csv
      headers = CSV::Row.new(used_extensions, used_extensions, true)

      tbl = CSV::Table.new([headers])

      # TODO: this is a heavy-handed hack to re-sync data
      # data.delete_if{|k,_| dwc_id_order[k].nil? }

      Rails.logger.debug 'dwca_export: extension in memory, pre-sort'

      data.sort_by {|k, _| dwc_id_order[k]}.each do |row|

        # remove collection object id, select "value" from hash conversion
        row = row[1]

        # Create empty row, this way we can insert columns by their headers, not by order
        csv_row = CSV::Row.new(used_extensions, [])

        # Add each [header, value] pair to the row
        row.each do |column_pair|
          unless column_pair.empty?
            csv_row[column_pair[0]] = Utilities::Strings.sanitize_for_csv(column_pair[1])
          end
        end

        tbl << csv_row
      end

      Rails.logger.debug 'dwca_export: extension in memory, post-sort'

      content = tbl.to_csv(col_sep: "\t", encoding: Encoding::UTF_8)

      @taxonworks_extension_data = Tempfile.new('tw_extension_data.tsv')
      @taxonworks_extension_data.write(content)
      @taxonworks_extension_data.flush
      @taxonworks_extension_data.rewind

      Rails.logger.debug 'dwca_export: taxonworks_extension_data prepared'

      @taxonworks_extension_data
    end

    # rubocop:enable Metrics/MethodLength

    def collecting_events
      s = 'WITH co_scoped AS (' + collection_objects.unscope(:order).select(:id, :collecting_event_id).to_sql + ') ' + ::CollectingEvent
        .joins('JOIN co_scoped as co_scoped1 on co_scoped1.collecting_event_id = collecting_events.id')
        .distinct
        .to_sql

      ::CollectingEvent.from('(' + s + ') as collecting_events')
    end

    def collection_object_attributes_query
      s = 'WITH touched_collection_objects AS (' + collection_objects.unscope(:order).select(:id).to_sql + ') ' + ::InternalAttribute
        .joins("JOIN touched_collection_objects as tco1 on data_attributes.attribute_subject_id = tco1.id AND data_attributes.attribute_subject_type = 'CollectionObject'")
        .to_sql

      ::InternalAttribute
        .joins(:predicate)
        .where(controlled_vocabulary_term_id: collection_object_predicate_ids)
        .from('(' + s + ') as data_attributes')
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
      s = 'WITH touched_collecting_events AS (' + collecting_events.to_sql + ') ' + ::InternalAttribute
        .joins("JOIN touched_collecting_events as tce1 on data_attributes.attribute_subject_id = tce1.id AND data_attributes.attribute_subject_type = 'CollectingEvent'")
        .where(controlled_vocabulary_term_id: collecting_event_predicate_ids)
        .to_sql

      ::InternalAttribute.from('(' + s + ') as data_attributes')
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
      s = 'WITH dwc_scoped AS (' + core_scope.unscope(:order).select('dwc_occurrences.dwc_occurrence_object_id, dwc_occurrences.dwc_occurrence_object_type').to_sql + ') ' + ::CollectionObject
        .joins("JOIN dwc_scoped as dwc_scoped1 on dwc_scoped1.dwc_occurrence_object_id = collection_objects.id and dwc_scoped1.dwc_occurrence_object_type = 'CollectionObject'")
        .select(:id, :collecting_event_id, :type)
        .to_sql

      ::CollectionObject.from('(' + s + ') as collection_objects')
    end


    # Finds which predicate columns in the temp table actually have non-NULL values
    # This is called after create_pivoted_predicate_table to filter out empty columns
    # Much faster than scanning data_attributes table
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
            .pluck(:name)
            .map { |name| "TW:DataAttribute:CollectionObject:#{name}" }

        ce_preds = collecting_event_predicate_ids.empty? ? [] :
          ControlledVocabularyTerm
            .where(id: collecting_event_predicate_ids)
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

      q = "SELECT id, CONCAT('TW:DataAttribute:CollectingEvent:', name) AS predicate_name
           FROM controlled_vocabulary_terms
           WHERE id IN (#{collecting_event_predicate_ids.join(',')})"

      ActiveRecord::Base.connection.execute(q).each_with_object({}) do |row, hash|
        hash[row['id'].to_i] = row['predicate_name']
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

      # Build aggregate statements for each CO predicate
      # Use MAX with FILTER which is more efficient than MAX(CASE...)
      # Sanitize values by replacing newlines and tabs with spaces (matching Utilities::Strings.sanitize_for_csv behavior)
      co_case_statements = co_pred_names.map do |cvt_id, pred_name|
        # Quote the column name to handle special characters
        quoted_name = conn.quote_column_name(pred_name)
        "MAX(REGEXP_REPLACE(co_da.value, E'[\\n\\t]', ' ', 'g')) FILTER (WHERE co_da.controlled_vocabulary_term_id = #{cvt_id}) AS #{quoted_name}"
      end

      # Build aggregate statements for each CE predicate
      # Sanitize values by replacing newlines and tabs with spaces
      ce_case_statements = ce_pred_names.map do |cvt_id, pred_name|
        quoted_name = conn.quote_column_name(pred_name)
        "MAX(REGEXP_REPLACE(ce_da.value, E'[\\n\\t]', ' ', 'g')) FILTER (WHERE ce_da.controlled_vocabulary_term_id = #{cvt_id}) AS #{quoted_name}"
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

      # Create ordering table based on dwc_occurrences.id order
      # This ensures we can join and order correctly without loading all IDs into Ruby
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

      # Get all possible predicates from configuration
      all_possible_predicates

      # if no predicate data found, return empty file
      if all_possible_predicates.empty?
        @predicate_data = Tempfile.new('predicate_data.tsv')
        return @predicate_data
      end

      # Create pivoted temp table with one row per CO, one column per predicate
      create_pivoted_predicate_table

      # Now query the temp table to find which columns actually have data
      used_preds = predicates_with_data

      # If no predicates have data, return empty file
      if used_preds.empty?
        @predicate_data = Tempfile.new('predicate_data.tsv')
        return @predicate_data
      end

      Rails.logger.debug 'dwca_export: predicate_data reading from temp table'

      conn = ActiveRecord::Base.connection

      # Build column list for only the predicates that have data
      column_list = used_preds.map { |pred| conn.quote_column_name(pred) }.join(', ')

      # Join with ordering table and let PostgreSQL handle the sorting
      # This avoids loading all IDs into Ruby memory
      sql = <<-SQL
        SELECT #{column_list}
        FROM temp_co_order
        LEFT JOIN temp_predicate_pivot ON temp_predicate_pivot.co_id = temp_co_order.co_id
        ORDER BY temp_co_order.ord
      SQL

      # Use PostgreSQL's COPY TO to generate TSV directly
      # This bypasses Ruby iteration entirely
      copy_sql = <<-SQL
        COPY (
          SELECT #{column_list}
          FROM temp_co_order
          LEFT JOIN temp_predicate_pivot ON temp_predicate_pivot.co_id = temp_co_order.co_id
          ORDER BY temp_co_order.ord
        ) TO STDOUT WITH (FORMAT CSV, DELIMITER E'\\t', HEADER, NULL '')
      SQL

      # Collect output from PostgreSQL
      content = String.new(encoding: Encoding::UTF_8)
      conn.raw_connection.copy_data(copy_sql) do
        while row = conn.raw_connection.get_copy_data
          content << row.force_encoding(Encoding::UTF_8)
        end
      end

      Rails.logger.debug 'dwca_export: predicate_data rows processed'

      @predicate_data = Tempfile.new('predicate_data.tsv')
      @predicate_data.write(content)
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

      join_data = [data]

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

      content = nil

      if no_records?
        content = "\n"
      else
        content = Export::CSV::Dwc::Extension::BiologicalAssociations.csv(biological_associations_extension, biological_association_relations_to_core)
      end

      @biological_associations_resource_relationship_tmp.write(content)
      @biological_associations_resource_relationship_tmp.flush
      @biological_associations_resource_relationship_tmp.rewind
      @biological_associations_resource_relationship_tmp
    end

    def media_tmp
      return nil if media_extension.nil? || media_extension.empty?
      @media_tmp = Tempfile.new('media.xml')

      content = nil
      if no_records?
        content = "\n"
      else
        content = Export::CSV::Dwc::Extension::Media.csv(media_extension[:collection_objects], media_extension[:field_occurrences])
      end

      @media_tmp.write(content)
      @media_tmp.flush
      @media_tmp.rewind
      @media_tmp
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
