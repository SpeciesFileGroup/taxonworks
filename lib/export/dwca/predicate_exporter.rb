module Export
  module Dwca
    # Service object for exporting predicate (data attribute) data in DwC-A format
    # Handles pivot table creation, predicate collection, and streaming export
    class PredicateExporter
      include Export::Dwca::PostgresqlFunctions

      # @param core_scope [ActiveRecord::Relation] DwcOccurrence scope for ordering
      # @param collection_object_predicate_ids [Array<Integer>] predicate IDs for collection objects
      # @param collecting_event_predicate_ids [Array<Integer>] predicate IDs for collecting events
      def initialize(core_scope:, collection_object_predicate_ids: [], collecting_event_predicate_ids: [])
        @core_scope = core_scope
        @collection_object_predicate_ids = collection_object_predicate_ids
        @collecting_event_predicate_ids = collecting_event_predicate_ids
      end

      # Main export method - writes predicate data to output file
      # @param output_file [Tempfile, File] output file for predicate TSV data
      # @return [Tempfile] the output file
      def export_to(output_file)
        # Create temporary function for sanitizing CSV values
        create_csv_sanitize_function

        # Get all possible predicates from configuration
        all_possible_predicates

        if all_possible_predicates.empty?
          return output_file
        end

        # Create pivoted temp table with one row per CO, one column per predicate
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

        # Stream output directly from PostgreSQL to file
        conn.raw_connection.copy_data(copy_sql) do
          while row = conn.raw_connection.get_copy_data
            output_file.write(row.force_encoding(Encoding::UTF_8))
          end
        end

        output_file.flush
        output_file.rewind

        Rails.logger.debug 'dwca_export: predicate_data written'

        output_file
      end

      private

      attr_reader :core_scope, :collection_object_predicate_ids, :collecting_event_predicate_ids

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
        conn.execute("DROP TABLE IF EXISTS temp_predicate_pivot")
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
        conn.execute("DROP TABLE IF EXISTS temp_co_order")
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
    end
  end
end
