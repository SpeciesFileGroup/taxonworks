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

      # Creates temporary PostgreSQL functions for generating image URLs
      # matching Shared::Api methods. The functions exist only for the current
      # database session.
      def create_image_url_functions
        conn = ActiveRecord::Base.connection
        host = conn.quote(Shared::Api.host)
        image_file_prefix = conn.quote(Shared::Api.image_file_url_prefix)
        image_metadata_prefix = conn.quote(Shared::Api.image_metadata_url_prefix)

        # Regular image file URL (fingerprint-based)
        conn.execute(<<~SQL)
          CREATE OR REPLACE FUNCTION pg_temp.image_file_url(fingerprint text, token text)
          RETURNS text AS $$
            SELECT #{image_file_prefix} || fingerprint || '?project_token=' || token
          $$ LANGUAGE SQL IMMUTABLE;
        SQL

        # Image metadata URL
        conn.execute(<<~SQL)
          CREATE OR REPLACE FUNCTION pg_temp.image_metadata_url(image_id integer, token text)
          RETURNS text AS $$
            SELECT #{image_metadata_prefix} || image_id::text || '?project_token=' || token
          $$ LANGUAGE SQL IMMUTABLE;
        SQL

        # Sled image file URL (fingerprint-based with crop coordinates)
        conn.execute(<<~SQL)
          CREATE OR REPLACE FUNCTION pg_temp.sled_image_file_url(fingerprint text, svg_view_box text, token text)
          RETURNS text AS $$
            SELECT #{image_file_prefix} || fingerprint || '/scale_to_box/'
              || SPLIT_PART(svg_view_box, ' ', 1)::integer::text || '/'
              || SPLIT_PART(svg_view_box, ' ', 2)::integer::text || '/'
              || SPLIT_PART(svg_view_box, ' ', 3)::integer::text || '/'
              || SPLIT_PART(svg_view_box, ' ', 4)::integer::text || '/'
              || SPLIT_PART(svg_view_box, ' ', 3)::integer::text || '/'
              || SPLIT_PART(svg_view_box, ' ', 4)::integer::text
              || '?project_token=' || token
          $$ LANGUAGE SQL IMMUTABLE;
        SQL
      end
  end
end
