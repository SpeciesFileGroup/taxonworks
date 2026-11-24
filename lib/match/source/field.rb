module Match
  module Source

    # One field of a citation (year, authors, title, ...) and everything
    # Match::Source::Candidates knows about comparing it: how a row's value
    # compares to a Source's, and how much an agreement counts when ordering
    # candidates.
    #
    # Subclasses implement #compare and #score; #prepare is for a field that
    # needs more than the Source's own columns (e.g. its DOIs), loaded once
    # for all candidates.
    #
    # A field instance lives for one Candidates#call, so it may memoize.
    class Field

      # @param rows [Array<Match::Source::InputRow>]
      # @param sources [Array<Source>] every gathered candidate
      def prepare(rows, sources); end

      # @param row [Match::Source::InputRow]
      # @param source [Source]
      # @return [Hash] this field's comparison keys, nil values when either
      #   side is missing
      def compare(row, source)
        raise NotImplementedError
      end

      # @param comparison [Hash] a candidate's merged comparisons
      # @return [Float] this field's part of the candidate's order score
      def score(comparison)
        raise NotImplementedError
      end

      private

      # Memoized, a candidate's text is compared against many rows and a
      # row's against many candidates.
      # @return [Set<String>]
      def trigrams(string)
        @trigrams ||= {}
        @trigrams[string] ||= ::Utilities::Strings.trigram_set(string)
      end

      # How alike two texts are, nil when either is missing.
      # @return [Float, nil] 0..1
      def similarity(a, b)
        return nil if a.nil? || b.nil?

        ::Utilities::Strings.trigram_set_similarity(trigrams(a), trigrams(b))
      end

      # How well `part` appears in `text` (e.g. a Source's title in a verbatim
      # citation), nil when either is missing.
      # @return [Float, nil] 0..1
      def word_similarity(part, text)
        return nil if part.nil? || text.nil?

        ::Utilities::Strings.trigram_word_similarity(
          trigrams(part), trigram_sequence(text)
        )
      end

      # @return [Array<String>]
      def trigram_sequence(string)
        @trigram_sequences ||= {}
        @trigram_sequences[string] ||= ::Utilities::Strings.trigram_sequence(string)
      end

    end
  end
end
