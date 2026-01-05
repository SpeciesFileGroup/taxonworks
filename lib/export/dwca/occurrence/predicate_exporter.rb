module Export::Dwca::Occurrence
  # Service object for exporting data attribute data in DwCA exports.
  class PredicateExporter
    include Export::Dwca::Occurrence::PostgresqlFunctions

    # @param core_scope [ActiveRecord::Relation] DwcOccurrence scope for ordering
    # @param collection_object_predicate_ids [Array<Integer>] predicate IDs for
    #   collection objects
    # @param collecting_event_predicate_ids [Array<Integer>] predicate IDs for
    #   collecting events
    def initialize(core_scope:, collection_object_predicate_ids: [], collecting_event_predicate_ids: [])
      @core_scope = core_scope
      @collection_object_predicate_ids = collection_object_predicate_ids
      @collecting_event_predicate_ids = collecting_event_predicate_ids
    end

    # Main export method - writes predicate data to output file.
    # @param output_file [Tempfile, File] output file for predicate TSV data
    # @return [Tempfile] the output file
    def export_to(output_file)
      create_csv_sanitize_function

      if all_possible_predicates.empty?
        return output_file
      end

      # Create pivoted temp table with one row per CO, one column per predicate.
      create_pivoted_predicate_table

      # Now query the temp table to find which columns actually have data
      used_preds = predicates_with_data

      if used_preds.empty?
        return output_file
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

      conn.raw_connection.copy_data(copy_sql) do
        while row = conn.raw_connection.get_copy_data
          output_file.write(row.force_encoding(Encoding::UTF_8))
        end
      end

      Rails.logger.debug 'dwca_export: predicate_data written'

      output_file
    ensure
      output_file.flush
      output_file.rewind
    end

    private

    def collecting_events
      ::CollectingEvent
        .with(co_scoped: collection_objects.unscope(:order).select(:id, :collecting_event_id))
        .joins('JOIN co_scoped ON co_scoped.collecting_event_id = collecting_events.id')
        .distinct
    end

    def collection_objects
      ::CollectionObject
        .with(dwc_scoped: @core_scope.unscope(:order).select(:dwc_occurrence_object_id, :dwc_occurrence_object_type))
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

    # All possible predicates based on configuration (not filtered by actual usage).
    def all_possible_predicates
      @all_possible_predicates ||= begin
        co_preds = @collection_object_predicate_ids.empty? ? [] :
          ControlledVocabularyTerm
            .where(id: @collection_object_predicate_ids)
            .order(:name)
            .pluck(:name)
            .map { |name| "TW:DataAttribute:CollectionObject:#{name}" }

        ce_preds = @collecting_event_predicate_ids.empty? ? [] :
          ControlledVocabularyTerm
            .where(id: @collecting_event_predicate_ids)
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
      return {} if @collection_object_predicate_ids.empty?

      q = "SELECT id, CONCAT('TW:DataAttribute:CollectionObject:', name) AS predicate_name
            FROM controlled_vocabulary_terms
            WHERE id IN (#{@collection_object_predicate_ids.join(',')})"

      ActiveRecord::Base.connection.execute(q).each_with_object({}) do |row, hash|
        hash[row['id'].to_i] = row['predicate_name']
      end
    end

    # @return [Hash]
    #   Maps cvt_id => full predicate name for collecting event predicates
    #   e.g., {456 => "TW:DataAttribute:CollectingEvent:bar"}
    def collecting_event_predicate_names
      return {} if @collecting_event_predicate_ids.empty?

      q = "SELECT id, name
            FROM controlled_vocabulary_terms
            WHERE id IN (#{@collecting_event_predicate_ids.join(',')})"

      ActiveRecord::Base.connection.execute(q).each_with_object({}) do |row, hash|
        hash[row['id'].to_i] = "TW:DataAttribute:CollectingEvent:#{row['name']}"
      end
    end

    # Creates a temporary table with one row per collection object
    # and one column per predicate (pivoted from tall to wide format).
    def create_pivoted_predicate_table
      conn = ActiveRecord::Base.connection

      conn.execute("DROP TABLE IF EXISTS temp_predicate_pivot")
      conn.execute("DROP TABLE IF EXISTS temp_co_order")

      co_pred_names = collection_object_predicate_names
      ce_pred_names = collecting_event_predicate_names

      delimiter = Shared::IsDwcOccurrence::DWC_DELIMITER
      co_case_statements = co_pred_names.map do |cvt_id, pred_name|
        # Quote the column name to handle special characters.
        quoted_name = conn.quote_column_name(pred_name)
        # Sanitize probably not needed here, though we don't explicitly do it
        # anywhere else in ruby code on DA values.
        "STRING_AGG(pg_temp.sanitize_csv(co_da.value), '#{delimiter}' ORDER BY co_da.id) FILTER (WHERE co_da.controlled_vocabulary_term_id = #{cvt_id}) AS #{quoted_name}"
      end

      ce_case_statements = ce_pred_names.map do |cvt_id, pred_name|
        quoted_name = conn.quote_column_name(pred_name)
        "STRING_AGG(pg_temp.sanitize_csv(ce_da.value), '#{delimiter}' ORDER BY ce_da.id) FILTER (WHERE ce_da.controlled_vocabulary_term_id = #{cvt_id}) AS #{quoted_name}"
      end

      all_case_statements = (co_case_statements + ce_case_statements).join(",\n      ")

      # If no predicates, create table with just co_id
      if all_case_statements.empty?
        all_case_statements = "NULL AS placeholder"
      end

      # Build the query.
      # Use collection_objects CTE to ensure all COs are included ,even those
      # without DAs.
      conn.execute("DROP TABLE IF EXISTS temp_predicate_pivot")
      sql = <<-SQL
        CREATE TEMP TABLE temp_predicate_pivot AS
        SELECT
          co.id as co_id
          #{all_case_statements.empty? ? '' : ',' + all_case_statements}
        FROM (#{collection_objects.unscope(:order).select(:id, :collecting_event_id).to_sql}) co
      SQL

      if co_pred_names.any?
        sql += <<-SQL
          LEFT JOIN data_attributes co_da ON co_da.attribute_subject_id = co.id
            AND co_da.attribute_subject_type = 'CollectionObject'
            AND co_da.type = 'InternalAttribute'
            AND co_da.controlled_vocabulary_term_id IN (#{co_pred_names.keys.join(',')})
        SQL
      end

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
      conn.execute("DROP TABLE IF EXISTS temp_co_order")
      order_sql = <<-SQL
        CREATE TEMP TABLE temp_co_order AS
        SELECT
          dwc_occurrences.dwc_occurrence_object_id as co_id,
          ROW_NUMBER() OVER (ORDER BY dwc_occurrences.id) as ord
        FROM (#{@core_scope.unscope(:order).to_sql}) dwc_occurrences
        WHERE dwc_occurrences.dwc_occurrence_object_type = 'CollectionObject'
      SQL

      conn.execute(order_sql)

      Rails.logger.debug 'dwca_export: co order temp table created'
    end
  end
end
