module Export::Dwca::Occurrence
  # PostgreSQL temporary function creators for DwC-A export
  # These functions exist only for the current database session
  module PostgresqlFunctions
      # Creates a temporary PostgreSQL function that sanitizes CSV values
      # by replacing newlines and tabs with spaces
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

      # Creates a temporary PostgreSQL function that builds API links for models,
      # matching Shared::Api.api_link_for_model_id
      # Handles all current dwc_occurrence_object_type values:
      #   - AssertedDistribution
      #   - CollectionObject
      #   - FieldOccurrence
      # @example
      #   api_link_for_model_id('CollectionObject', 123) → 'http://host/api/v1/collection_objects/123'
      #   api_link_for_model_id('FieldOccurrence', 456) → 'http://host/api/v1/field_occurrences/456'
      # The function exists only for the current database session.
      def create_api_link_for_model_id_function
        conn = ActiveRecord::Base.connection
        host = conn.quote(Shared::Api.host)
        conn.execute(<<~SQL)
          CREATE OR REPLACE FUNCTION pg_temp.api_link_for_model_id(model_type text, model_id integer)
          RETURNS text AS $$
            SELECT CASE
              WHEN model_type IS NULL OR model_id IS NULL THEN NULL
              WHEN model_type = 'AssertedDistribution' THEN #{host} || '/api/v1/asserted_distributions/' || model_id
              WHEN model_type = 'CollectionObject' THEN #{host} || '/api/v1/collection_objects/' || model_id
              WHEN model_type = 'FieldOccurrence' THEN #{host} || '/api/v1/field_occurrences/' || model_id
              ELSE NULL
            END
          $$ LANGUAGE SQL IMMUTABLE;
        SQL
      end
  end
end
