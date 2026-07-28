module Utilities
  class PageMap

    # A set of DocumentPages aligned against a set of PrintPages.
    #
    # This class was substantially authored by Claude.
    class Pair
      attr_reader :document, :print, :alignment

      def self.build(raw)
        hash = raw.transform_keys(&:to_s)

        new(
          document: RangeSet.build(hash['document']),
          print: RangeSet.build(hash['print']),
          alignment: hash['alignment']
        )
      end

      # @param document [RangeSet]
      # @param print [RangeSet, nil] nil means the DPs carry no printed number
      # @param alignment [String, nil] `positional` or `collective`. Inferred as
      #   positional when the flattened sizes match; never inferred otherwise.
      def initialize(document:, print: nil, alignment: nil)
        raise(FormatError, 'a pair needs a document range set') if document.nil?

        @alignment = resolve_alignment(document, print, alignment)

        canonical = @alignment == COLLECTIVE

        @document = canonical ? document.canonicalize : document
        @print = print.nil? || !canonical ? print : print.canonicalize
      end

      def unmapped?
        print.nil?
      end

      def document_pages
        document.to_a
      end

      # @yieldparam document_page [Integer, String]
      # @yieldparam print_page [PrintPage, nil]
      def each_mapping
        return enum_for(:each_mapping) unless block_given?

        if unmapped?
          document_pages.each { |dp| yield(dp, nil) }
          return
        end

        labels = print.to_a

        if alignment == POSITIONAL
          document_pages.each_with_index do |dp, i|
            yield(dp, labels[i].nil? ? nil : PrintPage.new(labels[i]))
          end
        else
          document_pages.each do |dp|
            labels.each { |label| yield(dp, PrintPage.new(label)) }
          end
        end
      end

      def as_json
        out = {
          'document' => document.as_json,
          'alignment' => alignment
        }

        out['print'] = print.as_json unless unmapped?
        out
      end

      def ==(other)
        other.is_a?(Pair) && as_json == other.as_json
      end

      private

      def resolve_alignment(document, print, given)
        given = given&.to_s

        if given && !ALIGNMENTS.include?(given)
          raise(FormatError, "unknown alignment: #{given.inspect}")
        end

        return COLLECTIVE if print.nil?
        return COLLECTIVE if given == COLLECTIVE

        unless document.size == print.size
          raise(AlignmentError,
            "#{document.size} document pages against #{print.size} print pages: " \
            'declare alignment "collective" when the sizes differ')
        end

        POSITIONAL
      end
    end
  end
end
