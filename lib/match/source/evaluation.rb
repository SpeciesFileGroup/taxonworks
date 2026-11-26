module Match
  module Source

    # Decides, for one row of Match::Source::Candidates#call, whether the row
    # is matched, and which candidates are worth showing, from what Candidates
    # judges without options: each candidate's `agrees` and `disagrees`
    # (Field#agrees?, Field#compared?) and `corroborated`.
    #
    # For callers that can't apply the Match sources task's options, e.g. the
    # API. The task judges in the browser, under the options the user sets
    # (app/javascript/vue/tasks/sources/match/utils/evaluate.js); this agrees
    # with its defaults on authors (Field::Authors#all_agree?), a shared DOI,
    # and preferring the project's Source, but requires corroboration, and
    # doesn't count a field missing on either side against a candidate.
    #
    # Usage:
    #   result = Match::Source::Candidates.new(...).call.first
    #   e = Match::Source::Evaluation.new(result)
    #   e.status # => :matched
    #   e.match # => the matched candidate (a Candidates candidate Hash)
    class Evaluation

      # A candidate disagreeing on any of these doesn't qualify (see
      # #qualifies?). Not the journal: the same journal is often named
      # differently (`J. Parasitol.`, `Journal of Parasitology`).
      REQUIRED = [
        Field::Doi, Field::Year, Field::Authors, Field::Title, Field::Volume,
        Field::Page
      ].map(&:key).freeze

      attr_reader :input, :candidates

      # @param result [Hash] one row of Match::Source::Candidates#call
      def initialize(result)
        @input = result[:input]
        @candidates = result[:candidates]
        @authors = Field::Authors.new
      end

      # @return [Symbol]
      #   :empty - the row has nothing to match on
      #   :matched - see #match
      #   :ambiguous - several candidates qualify, none stands out
      #   :unmatched - none do
      def status
        return :empty if input.empty?
        return :matched if match

        qualifying.any? ? :ambiguous : :unmatched
      end

      # @return [Hash, nil] the candidate the row matches: the only one with
      #   the row's DOI; otherwise the only one that qualifies; otherwise, of
      #   several that qualify, the only one in the project (as the Match
      #   sources task's default "prefer project Sources")
      def match
        return @match if defined?(@match)

        in_project = qualifying.select { |c| c[:in_project] }

        @match =
          if by_doi.one?
            by_doi.first
          elsif qualifying.one?
            qualifying.first
          elsif in_project.one?
            in_project.first
          end
      end

      # The DOI agrees, whatever else disagrees; or corroborated, disagreeing
      # on nothing REQUIRED, and, when the row has authors, all of them in
      # the Source (Field::Authors#all_agree?).
      def qualifies?(candidate)
        return true if candidate[:agrees].include?(:doi)

        candidate[:corroborated] &&
          (candidate[:disagrees] & REQUIRED).empty? &&
          (input.surnames.empty? || @authors.all_agree?(candidate))
      end

      # @return [Array<Hash>] the candidates worth showing: the corroborated
      #   ones, best first, the match (always corroborated) before them
      def listed
        corroborated = candidates.select { |c| c[:corroborated] }
        match ? [match] + (corroborated - [match]) : corroborated
      end

      private

      def by_doi
        @by_doi ||= candidates.select { |c| c[:agrees].include?(:doi) }
      end

      def qualifying
        @qualifying ||= candidates.select { |c| qualifies?(c) }
      end

    end
  end
end
