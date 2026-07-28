module Utilities
  class PageMap

    # One printed page label, carried verbatim.
    #
    # Either it is an integer, in which case it has a numeric value and sorts
    # numerically, or it is a string, in which case it does not and sorts
    # lexically. There is no third case: roman numerals, "Plate 12", "12a" and
    # URIs are all strings.
    #
    # This class was substantially authored by Claude.
    class PrintPage
      include Comparable

      INTEGER_PATTERN = /\A\d+\z/

      attr_reader :label

      # @param label [String, Integer] preserved verbatim
      def initialize(label)
        @label = label.to_s.dup.freeze
      end

      # @return [Boolean]
      def integer?
        !INTEGER_PATTERN.match(label.strip).nil?
      end

      # @return [Integer, nil] nil for every label that is not an integer
      def numeric_value
        return @numeric_value if defined?(@numeric_value)

        @numeric_value = integer? ? label.strip.to_i : nil
      end

      # The identity of the page: whitespace trimmed and collapsed, case
      # folded, and leading zeros dropped from integers, so "007" and "7" are
      # one page and so are "Plate 1" and "plate 1".
      #
      # Never a substring match: "30" is not "300".
      #
      # @return [String]
      def normalized_label
        @normalized_label ||=
          begin
            base = label.strip.downcase.gsub(/\s+/, ' ')
            integer? ? base.sub(/\A0+(?=\d)/, '') : base
          end
      end

      def ==(other)
        other.is_a?(PrintPage) && normalized_label == other.normalized_label
      end
      alias eql? ==

      def hash
        normalized_label.hash
      end

      # Total and stable. Integers ascending, then strings lexically.
      def <=>(other)
        return nil unless other.is_a?(PrintPage)

        mine = numeric_value
        theirs = other.numeric_value

        if mine && theirs
          mine <=> theirs
        elsif mine
          -1
        elsif theirs
          1
        else
          normalized_label <=> other.normalized_label
        end
      end

      def to_s
        label
      end

      def inspect
        "#<#{self.class.name} #{label.inspect}>"
      end

      def to_h
        { 'label' => label, 'integer' => integer?, 'numeric_value' => numeric_value }
      end
    end
  end
end
