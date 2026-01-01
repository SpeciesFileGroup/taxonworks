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
  end
end
