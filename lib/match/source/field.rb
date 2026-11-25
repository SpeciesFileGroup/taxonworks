module Match
  module Source

    # One field of a citation (year, authors, title, ...) and everything
    # Match::Source::Candidates knows about comparing it: how a row's value
    # compares to a Source's, and how much an agreement counts when ordering
    # candidates.
    #
    # Subclasses implement #compare, #score, #agrees? and #compared?; #prepare
    # is for a field that needs more than the Source's own columns (e.g. its
    # DOIs), or that compares in the database (Match::Source::Trigrams), done
    # once for all candidates.
    #
    # A field instance lives for one Candidates#call, so it may memoize.
    class Field

      # @return [Symbol] the field's name, e.g. :first_page
      def self.key
        name.demodulize.underscore.to_sym
      end

      # @param candidates [Hash] Match::Source::InputRow => [Source, ...], each
      #   row's gathered candidates
      def prepare(candidates); end

      # @param row [Match::Source::InputRow]
      # @param source [Source]
      # @return [Hash] this field's comparison keys, nil values when either
      #   side is missing
      def compare(row, source)
        raise NotImplementedError
      end

      # How well this field agrees, for ordering candidates; how much that
      # counts against the other fields is Candidates::FIELD_WEIGHTS.
      # @param comparison [Hash] a candidate's merged comparisons
      # @return [Float] 0 (no agreement, or not compared) .. 1 (full agreement)
      def score(comparison)
        raise NotImplementedError
      end

      # Whether this field agrees outright, e.g. the same year, a similar
      # title; see Candidates::CORROBORATING_ALONE.
      # @param comparison [Hash] a candidate's merged comparisons
      # @return [Boolean] false when not compared
      def agrees?(comparison)
        raise NotImplementedError
      end

      # Whether this field was compared: both the row and the Source have it.
      # @param comparison [Hash] a candidate's merged comparisons
      def compared?(comparison)
        raise NotImplementedError
      end

    end
  end
end
