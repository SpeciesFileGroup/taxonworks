# Gathers candidate Sources for rows of citation data and compares each
# candidate to its row field by field.
#
# No decision is made here as to which candidate (if any) *is* the match -
# each candidate carries per-field comparisons (year difference, author edit
# distances, title similarity, ...) and the caller applies whatever
# thresholds it wants to those.
#
# Usage:
#   Match::Source::Candidates.new(
#     rows: [{ authors: 'Ritzi, C.M. & J.O. Whitaker', year: '2003' }],
#     project_id: 1
#   ).call
#
# Returns an Array with one Hash per row:
#   [
#     {
#       index: 0,
#       input: <Match::Source::InputRow>, # the row as parsed
#       candidates: [
#         {
#           source: <Source>,
#           in_project: true,
#           year_difference: 0, # nil when either year is missing
#           year_suffix_match: nil, # nil when either suffix is missing
#           first_author_exact: true, # identical as written
#           first_author_distance: 0, # edit distance, diacritics/case
#             # folded, capped at AUTHOR_DISTANCE_CAP
#           author_distances: [0, 0], # per row surname, closest Source author
#           author_distance_matrix: [[0, 3], [3, 0]], # per row surname, to
#             # each Source surname, in order
#           first_author_initials_match: true, # nil when either has none;
#             # false when they share no initial (F.G.A.M. vs B.)
#           source_first_author_initials: ['C', 'M'],
#           source_author_count: 2,
#           title_similarity: 0.93, # 0..1 trigram similarity
#           journal_similarity: 0.61,
#           volume_match: true,
#           first_page_match: true,
#           doi_match: nil
#         }, ...
#       ]
#     }, ...
#   ]
#
# Claude (Anthropic) provided > 50% of the code for this class.
module Match
  module Source
    class Candidates

      # Candidates returned per row.
      CANDIDATES_LIMIT = 15

      # Candidates gathered per row and per gather strategy, before ranking.
      GATHER_LIMIT = 40

      # Low enough to gather misspelled and diacritic-variant surnames
      # (`Mueller` / `Müller` is ~0.5); the year window keeps the candidate
      # set small.
      AUTHOR_WORD_SIMILARITY_THRESHOLD = 0.4

      TEXT_SIMILARITY_THRESHOLD = 0.3

      # Author edit distances are reported up to this; anything larger is
      # reported as this.
      AUTHOR_DISTANCE_CAP = 4

      attr_reader :rows, :project_id, :limit_to_project, :year_window

      # @param rows [Array<Hash>] keys as Match::Source::InputRow#initialize
      # @param limit_to_project [Boolean] only Sources in the project
      # @param year_window [Integer] gather Sources up to this many years
      #   either side of the row's year
      def initialize(
        rows:, project_id:, limit_to_project: false, year_window: 2
      )
        @rows = rows.map { |r| InputRow.new(**r.to_h.symbolize_keys.slice(*INPUT_KEYS)) }
        @project_id = project_id
        @limit_to_project = limit_to_project
        @year_window = year_window.to_i
      end

      INPUT_KEYS = %i{authors year title journal volume pages doi verbatim}.freeze

      SOURCE_COLUMNS = %i{
        id type cached cached_author_string author year year_suffix volume pages
      }.freeze

      def call
        ids_by_row = gather

        all_ids = ids_by_row.values.flatten.uniq
        sources = ::Source
          .where(id: all_ids)
          .select(*SOURCE_COLUMNS)
          .index_by(&:id)
        in_project = ::ProjectSource
          .where(project_id:, source_id: all_ids)
          .pluck(:source_id)
          .to_set
        similarities = similarities_for(ids_by_row)
        @dois = dois_for(all_ids)

        rows.each_with_index.map do |row, index|
          candidates = (ids_by_row[index] || []).filter_map { |id|
            next if sources[id].nil?

            compare(
              row, sources[id], similarities[[index, id]] || {}
            ).merge(in_project: in_project.include?(id))
          }

          {
            index:,
            input: row,
            candidates: candidates
              .sort_by { |c| [-score(c), c[:source].id] }
              .first(CANDIDATES_LIMIT)
          }
        end
      end

      private

      # @return [Hash] row index => [source_id, ...]
      def gather
        result = Hash.new { |h, k| h[k] = [] }
        return result if rows.empty?

        ::Source.transaction do
          ::Source.connection.execute(
            'SET LOCAL pg_trgm.word_similarity_threshold = ' \
              "#{AUTHOR_WORD_SIMILARITY_THRESHOLD}"
          )
          ::Source.connection.execute(
            "SET LOCAL pg_trgm.similarity_threshold = #{TEXT_SIMILARITY_THRESHOLD}"
          )

          gather_by_doi(result)

          with_year = indexed_rows.select { |_, r| r.surnames.any? && r.year }
          gather_lateral(
            result, with_year,
            's.year BETWEEN q.year - ' \
              "#{year_window} AND q.year + #{year_window} AND " \
              'q.term <% s.cached_author_string'
          )

          without_year = indexed_rows.select { |_, r| r.surnames.any? && r.year.nil? }
          gather_lateral(result, without_year, 'q.term <% s.cached_author_string')

          # Nothing found from structured fields, try the text as a whole.
          by_text = indexed_rows.select { |i, r|
            result[i].empty? && (r.text || r.title)
          }
          gather_lateral(result, by_text, 's.cached % q.full_text')
        end

        result.transform_values(&:uniq)
      end

      def indexed_rows
        @indexed_rows ||= rows.each_with_index.map { |r, i| [i, r] }
          .reject { |_, r| r.empty? }
      end

      # DOIs are stored canonically as Identifier::Global::Doi (Source#doi
      # reads from there, the doi column is not normalized).
      def gather_by_doi(result)
        with_doi = indexed_rows.select { |_, r| r.doi }
        return if with_doi.empty?

        dois = with_doi.map { |_, r| quote(r.doi) }.uniq.join(', ')

        # A DOI can be on several Sources (e.g. one per project).
        found = Hash.new { |h, k| h[k] = [] }
        ::Source.connection.select_rows(<<~SQL).each { |id, doi|
          SELECT s.id, lower(trim(i.identifier))
          FROM identifiers i
          JOIN sources s ON s.id = i.identifier_object_id
          WHERE #{DOI_IDENTIFIER_CONDITION}
            AND lower(trim(i.identifier)) IN (#{dois})
            #{project_condition}
        SQL
          found[doi] << id
        }

        with_doi.each do |i, r|
          result[i].concat(found[r.doi]) if found.key?(r.doi)
        end
      end

      DOI_IDENTIFIER_CONDITION = "i.type = 'Identifier::Global::Doi' " \
        "AND i.identifier_object_type = 'Source'".freeze

      # @return [Hash] source_id => Set of lowercased DOIs
      def dois_for(source_ids)
        return {} if rows.none?(&:doi) || source_ids.empty?

        ::Source.connection.select_rows(<<~SQL)
          SELECT i.identifier_object_id, lower(trim(i.identifier))
          FROM identifiers i
          WHERE #{DOI_IDENTIFIER_CONDITION}
            AND i.identifier_object_id IN (#{source_ids.map(&:to_i).join(', ')})
        SQL
          .each_with_object(Hash.new { |h, k| h[k] = Set.new }) { |(id, doi), h|
            h[id] << doi
          }
      end

      def gather_lateral(result, indexed, condition)
        return if indexed.empty?

        ::Source.connection.select_rows(<<~SQL).each { |i, id| result[i] << id }
          SELECT q.idx, c.id
          FROM (VALUES #{values_sql(indexed)}) AS #{VALUES_ALIAS}
          CROSS JOIN LATERAL (
            SELECT s.id
            FROM sources s
            LEFT JOIN serials ser ON ser.id = s.serial_id
            WHERE #{condition}
              #{project_condition}
            ORDER BY #{RANK_SQL} DESC, s.id
            LIMIT #{GATHER_LIMIT}
          ) c
        SQL
      end

      VALUES_ALIAS = 'q(idx, term, first_surname, year, volume, first_page, ' \
        'title, journal, text, full_text)'.freeze

      TITLE_SQL = "regexp_replace(s.title, '<[^>]*>', '', 'g')".freeze

      # As InputRow.volume_number, lowercased.
      VOLUME_NUMBER_SQL = <<~SQL.squish.freeze
        lower(substring(
          regexp_replace(trim(s.volume), '^vol(ume)?\\.?\\s*', '', 'i')
          from '^[^\\s(:,;]+'
        ))
      SQL

      # The Source's first author's surname: cached_author_string is
      # `A`, `A & B`, or `A, B & C`.
      FIRST_AUTHOR_SQL =
        "split_part(split_part(s.cached_author_string, ',', 1), ' & ', 1)"
          .freeze

      # Only used to pick which candidates are kept, see #score for the
      # final order. The term matches anywhere in the author string, so the
      # first-author and journal terms keep a common surname's co-authored
      # and other-journal Sources from crowding out the row's.
      RANK_SQL = <<~SQL.squish.freeze
        (CASE WHEN s.year = q.year THEN 1 ELSE 0 END)
        + COALESCE(word_similarity(q.term, s.cached_author_string), 0)
        + (CASE WHEN lower(#{FIRST_AUTHOR_SQL}) = lower(q.first_surname)
          THEN 1 ELSE 0 END)
        + COALESCE(GREATEST(
          similarity(q.journal, s.journal), similarity(q.journal, ser.name)
        ), 0)
        + (CASE WHEN #{VOLUME_NUMBER_SQL} = q.volume THEN 1 ELSE 0 END)
        + (CASE WHEN substring(s.pages from '\\d+') = q.first_page
          THEN 1 ELSE 0 END)
        + COALESCE(similarity(q.title, s.title), 0)
        + COALESCE(word_similarity(s.title, q.text), 0)
      SQL

      # @return [Hash] [row index, source_id] => { title:, journal: }
      def similarities_for(ids_by_row)
        pairs = ids_by_row.flat_map { |i, ids| ids.map { |id| [i, id] } }
        return {} if pairs.empty?

        compared = indexed_rows.to_h.slice(*ids_by_row.keys)
        pair_values = pairs.map { |i, id| "(#{i.to_i}, #{id.to_i})" }.join(', ')

        ::Source.connection.select_rows(<<~SQL).to_h { |i, id, title, journal|
          SELECT p.idx, s.id,
            CASE
              WHEN q.title IS NOT NULL THEN similarity(q.title, #{TITLE_SQL})
              WHEN q.text IS NOT NULL THEN word_similarity(#{TITLE_SQL}, q.text)
            END,
            CASE
              WHEN q.journal IS NOT NULL THEN GREATEST(
                similarity(q.journal, s.journal),
                similarity(q.journal, ser.name)
              )
              WHEN q.text IS NOT NULL THEN GREATEST(
                word_similarity(s.journal, q.text),
                word_similarity(ser.name, q.text)
              )
            END
          FROM (VALUES #{pair_values}) AS p(idx, source_id)
          JOIN (VALUES #{values_sql(compared.to_a)}) AS #{VALUES_ALIAS}
            ON q.idx = p.idx
          JOIN sources s ON s.id = p.source_id
          LEFT JOIN serials ser ON ser.id = s.serial_id
        SQL
          [[i, id], { title: title&.to_f, journal: journal&.to_f }]
        }
      end

      def values_sql(indexed)
        indexed.map { |i, r|
          term = r.surnames.first.to_s.split.last
          full_text = [r.title, r.text].compact.join(' ').presence

          '(' + [
            i.to_i,
            "#{quote(term)}::text",
            "#{quote(r.surnames.first)}::text",
            "#{r.year.nil? ? 'NULL' : r.year.to_i}::int",
            "#{quote(r.volume&.downcase)}::text",
            "#{quote(r.first_page)}::text",
            "#{quote(r.title)}::text",
            "#{quote(r.journal)}::text",
            "#{quote(r.text)}::text",
            "#{quote(full_text)}::text"
          ].join(', ') + ')'
        }.join(', ')
      end

      def project_condition
        return '' if !limit_to_project

        'AND EXISTS (SELECT 1 FROM project_sources ps ' \
          "WHERE ps.source_id = s.id AND ps.project_id = #{project_id.to_i})"
      end

      def quote(value)
        ::Source.connection.quote(value)
      end

      def compare(row, source, similarities)
        source_surnames = source_surnames_for(source)
        first_input = row.surnames.first
        first_source = source_surnames.first
        source_initials = source_first_author_initials_for(source)
        source_volume = InputRow.volume_number(source.volume)
        # row surname => [distance to each Source surname]
        distances = row.surnames.map { |s|
          source_surnames.map { |t| surname_distance(s, t) }
        }

        {
          source:,
          year_difference: (row.year && source.year) ?
            (row.year - source.year).abs : nil,
          year_suffix_match: (row.year_suffix && source.year_suffix) ?
            row.year_suffix == source.year_suffix : nil,
          first_author_exact: (first_input && first_source) ?
            first_input.squish == first_source.squish : nil,
          first_author_distance: (first_input && first_source) ?
            surname_distance(first_input, first_source) : nil,
          author_distances: distances.map(&:min),
          author_distance_matrix: distances,
          first_author_initials_match:
            initials_match(row.first_author_initials, source_initials),
          source_first_author_initials: source_initials,
          source_author_count: source_surnames.size,
          title_similarity: similarities[:title],
          journal_similarity: similarities[:journal],
          # Source#volume often includes the issue, `65(1)`.
          volume_match: (row.volume && source_volume) ?
            row.volume.casecmp?(source_volume) : nil,
          first_page_match: (row.first_page && source.pages.present?) ?
            row.first_page == source.pages[/\d+/] : nil,
          doi_match: (row.doi && @dois.key?(source.id)) ?
            @dois[source.id].include?(row.doi) : nil
        }
      end

      # Folded edit distance, also trying the last word of each name so that
      # `van der Merwe` matches `Merwe`; capped at AUTHOR_DISTANCE_CAP.
      def surname_distance(a, b)
        surname_keys(a).product(surname_keys(b)).map { |x, y|
          if x == y
            0
          elsif (x.length - y.length).abs >= AUTHOR_DISTANCE_CAP
            AUTHOR_DISTANCE_CAP
          else
            [DidYouMean::Levenshtein.distance(x, y), AUTHOR_DISTANCE_CAP].min
          end
        }.min
      end

      def surname_keys(name)
        @surname_keys ||= {}
        @surname_keys[name] ||=
          [name, name.split.last]
            .map { |n| ::Utilities::AuthorNames.fold(n) }
            .reject(&:empty?).uniq
      end

      def source_surnames_for(source)
        @source_surnames ||= {}
        @source_surnames[source.id] ||=
          ::Utilities::AuthorNames.surnames(source.cached_author_string)
      end

      # A Source's `author` is BibTeX ("Last, Given and Last, Given").
      def source_first_author_initials_for(source)
        @source_initials ||= {}
        @source_initials[source.id] ||= ::Utilities::AuthorNames.initials(
          BibTeX::Names.parse(source.author.to_s)&.first&.first
        )
      end

      # Lenient on purpose: people go by a later given name (Jordan, K. is
      # Heinrich Ernst Karl), and lists get middle initials wrong (Amarga,
      # A.C. is Ace Kevin S.); only initials with nothing in common
      # disagree.
      #
      # @return [Boolean, nil] nil when either has no initials, otherwise
      #   whether they share an initial
      def initials_match(a, b)
        return nil if a.empty? || b.empty?

        a.intersect?(b)
      end

      def score(c)
        s = 0.0
        s += 4 if c[:doi_match]
        s += { 0 => 1.0, 1 => 0.5 }[c[:year_difference]].to_f
        s += 0.5 if c[:year_suffix_match]
        s += 1.0 if c[:first_author_distance] == 0
        s += 0.5 if c[:first_author_distance]&.between?(1, 2)
        if c[:author_distances].any?
          s += 0.5 * c[:author_distances].count { |d| d&.zero? } /
            [c[:author_distances].size, c[:source_author_count]].max
        end
        s += 1.0 if c[:volume_match]
        s += 1.0 if c[:first_page_match]
        s + c[:title_similarity].to_f + c[:journal_similarity].to_f
      end

    end
  end
end
