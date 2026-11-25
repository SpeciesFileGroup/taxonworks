module Match
  module Source

    # Finds the Sources worth comparing to each row, out of every Source, so
    # the choice is made in the database: one query per strategy, for all the
    # rows it applies to.
    #
    # Strategies, in order:
    # - DOI: every Source with the row's DOI
    # - surname and year, or surname alone when the row has no year: the
    #   row's best GATHER_LIMIT
    # - whole text, only for rows nothing was found for yet: the row's best
    #   GATHER_LIMIT
    # A row goes through at most one of the limited strategies, so it gets at
    # most GATHER_LIMIT Sources plus its DOI's.
    #
    # The SQL ranking (ORDER BY in #lateral) only decides which Sources are
    # kept; it deliberately repeats a rough version of some field comparisons
    # so that the row's own Source isn't crowded out by a common surname's
    # other works. What a field comparison *means* is in Match::Source::Field
    # and its subclasses, in Ruby, on what's gathered here.
    class Gather

      # Sources gathered per row by a surname or whole-text strategy.
      GATHER_LIMIT = 40

      # Low enough to gather misspelled and diacritic-variant surnames
      # (`Mueller` / `Müller` is ~0.5); the year window keeps the candidate
      # set small.
      AUTHOR_WORD_SIMILARITY_THRESHOLD = 0.4

      TEXT_SIMILARITY_THRESHOLD = 0.3

      attr_reader :indexed_rows, :project_id, :limit_to_project, :year_window

      # @param indexed_rows [Array] [[row index, Match::Source::InputRow], ...]
      #   non-empty rows only
      def initialize(
        indexed_rows:, project_id:, limit_to_project:, year_window:
      )
        @indexed_rows = indexed_rows
        @project_id = project_id
        @limit_to_project = limit_to_project
        @year_window = year_window
      end

      # @return [Hash] row index => [source_id, ...]
      def call
        result = Hash.new { |h, k| h[k] = [] }
        return result if indexed_rows.empty?

        ::Source.transaction do
          ::Source.connection.execute(
            'SET LOCAL pg_trgm.word_similarity_threshold = ' \
              "#{AUTHOR_WORD_SIMILARITY_THRESHOLD}"
          )
          ::Source.connection.execute(
            'SET LOCAL pg_trgm.similarity_threshold = ' \
              "#{TEXT_SIMILARITY_THRESHOLD}"
          )

          by_doi(result)

          with_year = indexed_rows.select { |_, r| r.surnames.any? && r.year }
          lateral(result, with_year, surname_condition(with_year: true))

          without_year = indexed_rows.select { |_, r|
            r.surnames.any? && r.year.nil?
          }
          lateral(result, without_year, surname_condition(with_year: false))

          # Rows nothing was found for yet (no DOI, no surname match): match
          # the whole citation text against each Source's `cached`.
          by_text = indexed_rows.select { |i, r|
            result[i].empty? && (r.unparsed_text || r.title)
          }
          lateral(result, by_text, 's.cached % input_row.full_text')
        end

        result.transform_values(&:uniq)
      end

      private

      def by_doi(result)
        with_doi = indexed_rows.select { |_, r| r.doi }
        return if with_doi.empty?

        scope = Field::Doi.identifiers
        if limit_to_project
          scope = scope.where(
            identifier_object_id:
              ::ProjectSource.where(project_id:).select(:source_id)
          )
        end

        # A DOI should be on at most one Source, but the uniqueness validation
        # misses case variants (`10.1007/BF02372110` vs `10.1007/bf02372110`)
        # and some exact duplicates exist anyway; gather them all, so the row
        # shows as ambiguous.
        # TODO: remove the several-Sources handling here (and the 'a DOI on
        # several Sources' spec) once the Identifier::Global DOI validation is
        # case-insensitive and the existing duplicates are resolved.
        found = Field::Doi.source_ids_by_doi(
          with_doi.map { |_, r| r.doi }.uniq, scope
        )

        with_doi.each do |i, r|
          result[i].concat(found[r.doi]) if found.key?(r.doi)
        end
      end

      # The row's first surname is in the Source's authors, and its year within
      # year_window when it has one. Either the surname's first or last word
      # will do, since one side may cite only part of a compound surname
      # (`García López` as `García`, `Gomes Alves` as `Alves`); a particle is
      # never a surname's word (`van der Merwe`).
      # @return [String] SQL for #lateral
      def surname_condition(with_year:)
        surname =
          # (<% is trigram includes: is LHS trigram-similar to a substring of RHS?)
          '(input_row.first_word <% s.cached_author_string OR ' \
            'input_row.last_word <% s.cached_author_string)'
        return surname if !with_year

        's.year BETWEEN input_row.year - ' \
          "#{year_window} AND input_row.year + #{year_window} AND #{surname}"
      end

      # @param indexed [Array] [[row index, InputRow], ...] to gather for
      # @param condition [String] SQL a Source must meet for row `input_row`
      def lateral(result, indexed, condition)
        return if indexed.empty?

        project_filter =
          if limit_to_project
            'AND EXISTS (SELECT 1 FROM project_sources ps ' \
              'WHERE ps.source_id = s.id ' \
              "AND ps.project_id = #{project_id.to_i})"
          end

        # `input_row` is one row of the input, see #values_sql. The ORDER BY
        # scores how well a Source agrees with it, each term 0..1, all counting
        # the same: it only has to keep the row's Source among those gathered
        # (Candidates orders them, by Candidates::FIELD_WEIGHTS). The surname
        # words match anywhere in the author string, so the first-author and
        # journal terms keep a common surname's co-authored and other-journal
        # Sources from crowding out the row's.
        ::Source.connection.select_rows(<<~SQL).each { |i, id| result[i] << id }
          SELECT input_row.idx, candidate.id
          FROM (VALUES #{values_sql(indexed)})
            AS input_row(idx, first_word, last_word, first_surname, year,
              volume, first_page, title, journal, unparsed_text, full_text)
          CROSS JOIN LATERAL (
            SELECT s.id
            FROM sources s
            LEFT JOIN serials ser ON ser.id = s.serial_id
            WHERE #{condition}
              #{project_filter}
            ORDER BY
              -- add up column matching scores against multiple columns:
              (CASE WHEN s.year = input_row.year THEN 1 ELSE 0 END)
              + COALESCE(GREATEST(
                word_similarity(input_row.first_word, s.cached_author_string),
                word_similarity(input_row.last_word, s.cached_author_string)
              ), 0)
              -- the first author; cached_author_string is `A`, `A & B`,
              -- or `A, B & C`
              + (CASE WHEN lower(split_part(
                  split_part(s.cached_author_string, ',', 1), ' & ', 1
                )) = lower(input_row.first_surname) THEN 1 ELSE 0 END)
              + COALESCE(GREATEST(
                similarity(input_row.journal, s.journal),
                similarity(input_row.journal, ser.name)
              ), 0)
              -- the volume number, as Utilities::Bibliography.volume_number
              + (CASE WHEN lower(substring(
                  regexp_replace(trim(s.volume), '^vol(ume)?\\.?\\s*', '', 'i')
                  from '^[^\\s(:,;]+'
                )) = input_row.volume THEN 1 ELSE 0 END)
              + (CASE WHEN substring(s.pages from '\\d+') = input_row.first_page
                THEN 1 ELSE 0 END)
              + COALESCE(similarity(input_row.title, s.title), 0)
              + COALESCE(word_similarity(s.title, input_row.unparsed_text), 0)
              DESC,
              s.id
            LIMIT #{GATHER_LIMIT}
          ) candidate
        SQL
      end

      def values_sql(indexed)
        indexed.map { |i, r|
          words = ::Utilities::AuthorNames.surname_words(r.surnames.first)
          full_text = [r.title, r.unparsed_text].compact.join(' ').presence

          '(' + [
            i.to_i,
            "#{quote(words.first)}::text",
            "#{quote(words.last)}::text",
            "#{quote(r.surnames.first)}::text",
            "#{r.year.nil? ? 'NULL' : r.year.to_i}::int",
            "#{quote(r.volume&.downcase)}::text",
            "#{quote(r.first_page)}::text",
            "#{quote(r.title)}::text",
            "#{quote(r.journal)}::text",
            "#{quote(r.unparsed_text)}::text",
            "#{quote(full_text)}::text"
          ].join(', ') + ')'
        }.join(', ')
      end

      def quote(value)
        ::Source.connection.quote(value)
      end

    end
  end
end
