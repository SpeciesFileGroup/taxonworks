module Utilities
  class PageMap

    # An ordered set of ranges and singletons. A plain range is a one member
    # RangeSet; a discontiguous page is a set of several.
    #
    # This class was substantially authored by Claude.
    class RangeSet
      include Enumerable

      attr_reader :members

      def self.build(raw)
        return nil if raw.nil?
        return raw if raw.is_a?(RangeSet)

        members = raw.is_a?(Array) ? raw : [raw]
        new(members.map { |m| Segment.build(m) })
      end

      def initialize(members)
        @members = members
      end

      def size
        @size ||= members.sum(&:size)
      end
      alias length size

      def single_member?
        members.size == 1
      end

      def to_a
        @to_a ||= members.flat_map(&:to_a)
      end
      alias flatten to_a

      def each(&block)
        to_a.each(&block)
      end

      # O(members) with no expansion of the underlying ranges.
      def include?(candidate)
        members.any? { |m| m.include?(candidate) }
      end

      # Sorting and merging is only safe where member order carries no meaning,
      # which is to say collective pairs. A positional pair keeps the author's
      # order verbatim, because that order IS the mapping.
      def canonicalize
        integers, others = members.partition(&:integer_like?)

        merged = []

        integers.map(&:bounds).sort_by(&:first).each do |from, to|
          last = merged.last

          if last && from <= last[1] + 1
            last[1] = [last[1], to].max
          else
            merged << [from, to]
          end
        end

        rebuilt = merged.map do |from, to|
          from == to ? Segment.new(type: :literal, value: from) : Segment.new(type: :integer, from:, to:)
        end

        seen = {}
        others.each do |segment|
          seen[segment.as_json] ||= segment
        end

        RangeSet.new(rebuilt + seen.values)
      end

      def as_json
        members.map(&:as_json)
      end

      def ==(other)
        other.is_a?(RangeSet) && as_json == other.as_json
      end
    end
  end
end
