# Gathers candidate Sources for rows of citation data and compares each
# candidate to its row field by field.
#
# No decision is made here as to which candidate (if any) *is* the match -
# each candidate carries per-field comparisons (year difference, author edit
# distances, title similarity, ...) and the caller applies whatever
# thresholds it wants to those.
#
# Candidates are found by Match::Source::Gather (SQL), then compared in Ruby
# by each Match::Source::Field in FIELDS, which also gives its part of the
# score candidates are ordered by.
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
#           author_distance_matrix: [[0, 3], [3, 0]], # per row surname, to
#             # each Source surname, in order
#           first_author_initials_match: true, # nil when either has none;
#             # false when they share no initial (F.G.A.M. vs B.)
#           source_first_author_initials: ['C', 'M'],
#           source_author_count: 2,
#           title_similarity: 0.93, # 0..1 trigram similarity, or for a
#             # verbatim row the share of the title found in it
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

      # Row keys accepted, as Match::Source::InputRow#initialize.
      INPUT_KEYS = %i{authors year title journal volume pages doi verbatim}.freeze

      FIELDS = [
        Field::Doi, Field::Year, Field::Authors, Field::Title, Field::Journal,
        Field::Volume, Field::FirstPage
      ].freeze

      # Source columns loaded, beyond those the FIELDS compare: what's
      # rendered for a candidate.
      SOURCE_COLUMNS = %i{id type cached}.freeze

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
          .select(*(SOURCE_COLUMNS + FIELDS.flat_map(&:source_columns)).uniq)
          .index_by(&:id)
        in_project = ::ProjectSource
          .where(project_id:, source_id: all_ids)
          .pluck(:source_id)
          .to_set

        fields = FIELDS.map(&:new)
        fields.each { |f| f.prepare(rows, sources.values) }

        rows.each_with_index.map do |row, index|
          candidates = (ids_by_row[index] || []).filter_map { |id|
            next if sources[id].nil?

            compare(row, sources[id], fields)
              .merge(in_project: in_project.include?(id))
          }

          {
            index:,
            input: row,
            candidates: candidates
              .sort_by { |c| [-fields.sum { |f| f.score(c) }, c[:source].id] }
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
