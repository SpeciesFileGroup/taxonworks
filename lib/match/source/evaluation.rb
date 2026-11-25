module Match
  module Source

    # Decides, for one row of Match::Source::Candidates#call, whether the row
    # is matched, and which candidates are worth showing, from what Candidates
    # judges without options: each candidate's `agrees` and `disagrees`
    # (Field#agrees?, Field#compared?) and `corroborated`.
    #
    # Not the Match sources task's judgment: the task applies the options the
    # user sets, in the browser (app/javascript/vue/tasks/sources/match/
    # utils/evaluate.js), and may decide differently; this is for callers that
    # can't, e.g. the API.
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
        Field::FirstPage
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
      #   :ambiguous - several candidates share the row's DOI, or qualify
      #   :unmatched - none do
      def status
        return :empty if input.empty?
        return :matched if match

        by_doi.any? || qualifying.any? ? :ambiguous : :unmatched
      end

      # @return [Hash, nil] the candidate the row matches: the only one with
      #   the row's DOI, whatever else disagrees; otherwise the only one that
      #   qualifies
      def match
        return @match if defined?(@match)

        @match =
          if by_doi.any?
            by_doi.first if by_doi.one?
          elsif qualifying.one?
            qualifying.first
          end
      end

      # Corroborated, disagreeing on nothing REQUIRED, and, when the row has
      # authors, all of them in the Source (Field::Authors#all_agree?).
      def qualifies?(candidate)
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
