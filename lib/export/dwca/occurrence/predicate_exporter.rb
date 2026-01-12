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
      return output_file if all_possible_predicates.empty?

      create_pivoted_predicate_tables

      used_preds = predicates_with_data
      return output_file if used_preds.empty?

      Rails.logger.debug 'dwca_export: predicate_data reading from temp table'

      conn = ActiveRecord::Base.connection
      column_list = used_preds.map { |pred| conn.quote_column_name(pred) }.join(', ')

      copy_sql = <<-SQL
        COPY (
          SELECT #{column_list}
          FROM temp_co_order
          LEFT JOIN temp_predicate_pivot ON temp_predicate_pivot.co_id = temp_co_order.co_id
          ORDER BY temp_co_order.ord
        ) TO STDOUT WITH (FORMAT CSV, DELIMITER E'\\t', HEADER, NULL '')
      SQL

      conn.raw_connection.copy_data(copy_sql) do
        while (row = conn.raw_connection.get_copy_data)
          output_file.write(row.force_encoding(Encoding::UTF_8))
        end
      end

      Rails.logger.debug 'dwca_export: predicate_data written'
      output_file
    ensure
      cleanup_temp_tables
      output_file.flush
      output_file.rewind
    end

    private

    def cleanup_temp_tables
      conn = ActiveRecord::Base.connection
      conn.execute('DROP TABLE IF EXISTS temp_predicate_pivot')
      conn.execute('DROP TABLE IF EXISTS temp_predicate_pivot_co')
      conn.execute('DROP TABLE IF EXISTS temp_predicate_pivot_ce')
      conn.execute('DROP TABLE IF EXISTS temp_co_order')
    end

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

    # Finds which predicate columns in the combined temp table actually have non-NULL values.
    def predicates_with_data
      return [] if all_possible_predicates.empty?

      conn = ActiveRecord::Base.connection

      checks = all_possible_predicates.map.with_index do |pred, idx|
        quoted = conn.quote_column_name(pred)
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

    # - temp_predicate_pivot_co: pivot CO attributes only, grouped by co_id
    # - temp_predicate_pivot_ce: pivot CE attributes only, grouped by collecting_event_id
    # - temp_predicate_pivot: join the two pivots (1 row per co_id), no join fan-out
    # - temp_co_order: stable output ordering
    def create_pivoted_predicate_tables
      conn = ActiveRecord::Base.connection

      # Defensive cleanup in case a previous run died mid-stream on a pooled connection.
      conn.execute('DROP TABLE IF EXISTS temp_predicate_pivot')
      conn.execute('DROP TABLE IF EXISTS temp_predicate_pivot_co')
      conn.execute('DROP TABLE IF EXISTS temp_predicate_pivot_ce')
      conn.execute('DROP TABLE IF EXISTS temp_co_order')

      co_pred_names = collection_object_predicate_names
      ce_pred_names = collecting_event_predicate_names
      delimiter = Shared::IsDwcOccurrence::DWC_DELIMITER

      co_src_sql = collection_objects
        .unscope(:order)
        .select(:id, :collecting_event_id)
        .to_sql

      # CollectionObject pivot.
      co_select_cols = co_pred_names.map do |cvt_id, pred_name|
        quoted_name = conn.quote_column_name(pred_name)
        "STRING_AGG(pg_temp.sanitize_csv(co_da.value), '#{delimiter}' ORDER BY co_da.id)
         FILTER (WHERE co_da.controlled_vocabulary_term_id = #{cvt_id}) AS #{quoted_name}"
      end

      co_cols_sql = co_select_cols.any? ?
        ",\n  #{co_select_cols.join(",\n  ")}" : ''

      co_join_sql = if co_pred_names.any?
        <<~SQL
          LEFT JOIN data_attributes co_da ON co_da.attribute_subject_id = co.id
            AND co_da.attribute_subject_type = 'CollectionObject'
            AND co_da.type = 'InternalAttribute'
            AND co_da.controlled_vocabulary_term_id IN (#{co_pred_names.keys.join(',')})
        SQL
      else
        ''
      end

      co_sql = <<~SQL
        CREATE TEMP TABLE temp_predicate_pivot_co AS
        SELECT
          co.id AS co_id,
          co.collecting_event_id AS collecting_event_id#{co_cols_sql}
        FROM (#{co_src_sql}) co
        #{co_join_sql}
        GROUP BY co.id, co.collecting_event_id
      SQL

      conn.execute(co_sql)
      Rails.logger.debug 'dwca_export: temp_predicate_pivot_co created'

      # CollectingEvent pivot.
      if ce_pred_names.any?
        ce_select_cols = ce_pred_names.map do |cvt_id, pred_name|
          quoted_name = conn.quote_column_name(pred_name)
          "STRING_AGG(pg_temp.sanitize_csv(ce_da.value), '#{delimiter}' ORDER BY ce_da.id)
           FILTER (WHERE ce_da.controlled_vocabulary_term_id = #{cvt_id}) AS #{quoted_name}"
        end

        ce_cols_sql = ce_select_cols.any? ?
          ",\n  #{ce_select_cols.join(",\n  ")}" : ''

        ce_sql = <<~SQL
          CREATE TEMP TABLE temp_predicate_pivot_ce AS
          SELECT
            ce.id AS collecting_event_id#{ce_cols_sql}
          FROM collecting_events ce
          JOIN (SELECT DISTINCT collecting_event_id FROM temp_predicate_pivot_co) co
            ON co.collecting_event_id = ce.id
          LEFT JOIN data_attributes ce_da ON ce_da.attribute_subject_id = ce.id
            AND ce_da.attribute_subject_type = 'CollectingEvent'
            AND ce_da.type = 'InternalAttribute'
            AND ce_da.controlled_vocabulary_term_id IN (#{ce_pred_names.keys.join(',')})
          GROUP BY ce.id
        SQL

        conn.execute(ce_sql)
        Rails.logger.debug 'dwca_export: temp_predicate_pivot_ce created'
      end

      # Combined pivot.
      combined_cols = []
      combined_cols << 'co.co_id'

      co_pred_names.values.each do |pred_name|
        combined_cols << "co.#{conn.quote_column_name(pred_name)}"
      end

      if ce_pred_names.any?
        ce_pred_names.values.each do |pred_name|
          combined_cols << "ce.#{conn.quote_column_name(pred_name)}"
        end
      end

      combined_join_sql = if ce_pred_names.any?
        <<~SQL
          LEFT JOIN temp_predicate_pivot_ce ce
            ON ce.collecting_event_id = co.collecting_event_id
        SQL
      else
        ''
      end

      combined_sql = <<~SQL
        CREATE TEMP TABLE temp_predicate_pivot AS
        SELECT
          #{combined_cols.join(",\n    ")}
        FROM temp_predicate_pivot_co co
        #{combined_join_sql}
      SQL

      conn.execute(combined_sql)
      Rails.logger.debug 'dwca_export: temp_predicate_pivot created'

      order_sql = <<-SQL
        CREATE TEMP TABLE temp_co_order AS
        SELECT
          dwc_occurrences.dwc_occurrence_object_id as co_id,
          ROW_NUMBER() OVER (ORDER BY dwc_occurrences.id) as ord
        FROM (#{@core_scope.unscope(:order).to_sql}) dwc_occurrences
        WHERE dwc_occurrences.dwc_occurrence_object_type = 'CollectionObject'
      SQL

      conn.execute(order_sql)
      Rails.logger.debug 'dwca_export: temp_co_order created'
    end
  end
end
