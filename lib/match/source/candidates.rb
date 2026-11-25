# Gathers candidate Sources for rows of citation data and compares each
# candidate to its row field by field.
#
# No decision is made here as to which candidate (if any) *is* the match -
# each candidate carries per-field comparisons (year difference, author edit
# distances, title similarity, ...) and the caller applies whatever
# thresholds it wants to those.
#
# Candidates are found by Match::Source::Gather (SQL), then compared in Ruby
# by each Match::Source::Field in FIELD_WEIGHTS, and ordered by the fields'
# weighted agreement.
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
#             # folded, capped at Field::Authors::DISTANCE_CAP
#           author_distances: [0, 0], # per row surname, closest Source author
#           matched_author_counts: [2, 2, 2, 2], # row authors paired with
#             # a Source author, per max edits 0..Field::Authors::MAX_EDITS
#           first_author_initials_match: true, # nil when either has none;
#             # false when they share no initial (F.G.A.M. vs B.)
#           source_first_author_initials: ['C', 'M'],
#           source_author_count: 2,
#           title_similarity: 0.93, # 0..1 trigram similarity, or for a
#             # verbatim row the share of the title found in it
#           journal_similarity: 0.61,
#           volume_match: true,
#           first_page_match: true,
#           doi_match: nil,
#           corroborated: true # enough fields agree to list the candidate
#             # when none pass, see CORROBORATING_ALONE
#         }, ...
#       ]
#     }, ...
#   ]
#
# Claude (Anthropic) provided > 50% of the code for this class.
module Match
  module Source
    class Candidates

      # Max candidates returned per row.
      CANDIDATES_LIMIT = 15

      # Row keys accepted, as Match::Source::InputRow#initialize.
      INPUT_KEYS = %i{authors year title journal volume pages doi verbatim}.freeze

      # The fields compared, and how much each one's agreement (0..1, see
      # Field#score) counts when ordering candidates. A shared DOI outweighs
      # most other agreement. The title counts a little more than the journal:
      # an author's works of a year are often in the same journal, rarely
      # under similar titles. (Measured on real data, the weights barely
      # change outcomes; they order the candidates that pass.)
      FIELD_WEIGHTS = {
        Field::Doi => 4.0,
        Field::Year => 1.5,
        Field::Authors => 1.5,
        Field::Title => 1.25,
        Field::Journal => 1.0,
        Field::Volume => 1.0,
        Field::FirstPage => 1.0
      }.freeze

      # A candidate is `corroborated` when one of these fields agrees (see
      # Field#agrees?): each is strong evidence on its own.
      CORROBORATING_ALONE = [Field::Doi, Field::Title].freeze

      # ... or when CORROBORATING_COUNT of these agree: each is weak evidence
      # on its own. The year is shared by an author's works of a year, and the
      # journal by many of them; a volume or first page may agree by chance
      # (`1`). The authors count, but never alone: most candidates are
      # gathered by the row's first surname (see Match::Source::Gather), so
      # their first author agreeing is expected; with one more field it tells
      # a candidate apart from the author's other works.
      CORROBORATING_TOGETHER = [
        Field::Authors, Field::Year, Field::Journal, Field::Volume,
        Field::FirstPage
      ].freeze

      CORROBORATING_COUNT = 2

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

      def call
        ids_by_row = Gather.new(
          indexed_rows:, project_id:, limit_to_project:, year_window:
        ).call

        all_ids = ids_by_row.values.flatten.uniq
        sources = ::Source
          .where(id: all_ids)
          .index_by(&:id)
        in_project = ::ProjectSource
          .where(project_id:, source_id: all_ids)
          .pluck(:source_id)
          .to_set

        # row => [Source, ...]
        sources_by_row = rows.each_with_index.to_h { |row, index|
          [row, (ids_by_row[index] || []).filter_map { |id| sources[id] }]
        }

        weights = FIELD_WEIGHTS.to_h { |klass, weight| [klass.new, weight] }
        fields = weights.keys
        fields.each { |f| f.prepare(sources_by_row) }
        alone = fields.select { |f| CORROBORATING_ALONE.include?(f.class) }
        together = fields.select { |f|
          CORROBORATING_TOGETHER.include?(f.class)
        }

        rows.each_with_index.map do |row, index|
          candidates = sources_by_row[row].map { |source|
            c = compare(row, source, fields)
            c.merge(
              in_project: in_project.include?(source.id),
              corroborated: alone.any? { |f| f.agrees?(c) } ||
                together.count { |f| f.agrees?(c) } >= CORROBORATING_COUNT
            )
          }

          {
            index:,
            input: row,
            candidates: candidates
              .sort_by { |c|
                score = weights.sum { |f, weight| weight * f.score(c) }
                [-score, c[:source].id]
              }
              .first(CANDIDATES_LIMIT)
          }
        end
      end

      private

      def indexed_rows
        rows.each_with_index.map { |r, i| [i, r] }.reject { |_, r| r.empty? }
      end

      def compare(row, source, fields)
        fields.each_with_object({ source: }) { |f, h|
          h.merge!(f.compare(row, source))
        }
      end

    end
  end
end
