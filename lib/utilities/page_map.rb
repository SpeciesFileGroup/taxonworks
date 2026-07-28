require 'json'

module Utilities

  # A map between the pages of a document artifact (DocumentPage, "DP") and the
  # page labels printed in its content (PrintPage, "PP").
  #
  # This class was substantially authored by Claude against
  # `_development/prompts/page_map.md`.
  #
  # It is a self-contained library: it knows nothing about any host application,
  # framework, ORM, or database. It reads no configuration, touches no
  # filesystem, and makes no network call. A host wraps it; that wrapper is not
  # anticipated here.
  #
  # The parts live in `lib/utilities/page_map/` and are loaded by the host's
  # autoloader. Nothing here requires them, because in this application Zeitwerk
  # manages `lib`, and a file it manages must not be required by hand. Outside
  # Rails, require the directory before this file.
  #
  # * `PageMap::PrintPage` — one printed page label
  # * `PageMap::Segment`   — one member of a range set
  # * `PageMap::RangeSet`  — an ordered set of ranges and singletons
  # * `PageMap::Pair`      — a set of DPs aligned against a set of PPs
  #
  # Roman numeral conversion lives in `Utilities::Roman`, which is general
  # purpose and knows nothing about pages.
  #
  # The atomic unit is a Pair. A single page is a degenerate set of one range of
  # length one, so a 900 page scan packs to one Pair rather than 900 keys.
  #
  #   map = Utilities::PageMap.unpack(
  #     [
  #       { 'document' => [{ 'from' => 1, 'to' => 4 }],
  #         'print' => [{ 'from' => 'i', 'to' => 'iv', 'roman' => true }] },
  #       { 'document' => [{ 'from' => 5, 'to' => 304 }],
  #         'print' => [{ 'from' => 1, 'to' => 300 }] }
  #     ]
  #   )
  #
  #   map.document_page('12')  # => [16]
  #   map.print_page(16)       # => [#<PrintPage '12'>]
  #   map.total_pages          # => 304
  #
  # The packed form is an Array of pairs, and its order is meaningful: a later
  # pair wins for the document pages it names. That is what makes correcting a
  # page an append rather than a second kind of record. JSON arrays keep their
  # order, including through PostgreSQL jsonb, which reorders object keys but
  # never array elements.
  #
  # An Array is the packed form and a Hash is the expanded
  # `{ document page => label(s) }` form. Nothing else is accepted.
  #
  # A printed page label is one of two things: an integer, or a string. Integers
  # sort and shift and can be expressed as ranges; everything else, roman
  # numerals and "Plate 12" and URIs alike, is carried verbatim as a string and
  # compared as one.
  #
  # A label that appears on more than one document page is one printed page, not
  # several. `document_page` returns every document page bearing it.
  class PageMap

    Error = Class.new(StandardError)

    # A packed structure could not be read.
    FormatError = Class.new(Error)

    # Flattened set sizes disagree and `collective` was not declared.
    AlignmentError = Class.new(Error)

    # A range was too large to expand.
    ExpansionError = Class.new(Error)

    POSITIONAL = 'positional'.freeze
    COLLECTIVE = 'collective'.freeze

    ALIGNMENTS = [POSITIONAL, COLLECTIVE].freeze

    # Guards against a hostile or mistaken range like 1..10_000_000.
    MAX_EXPANSION = 100_000

    attr_reader :pairs

    class << self

      # Read a map from a packed Array, an expanded Hash, or a JSON String of
      # either. The JSON type is the discriminator: an Array is packed, a Hash
      # is expanded.
      #
      # @param raw [Array, Hash, String, nil]
      # @return [PageMap]
      def unpack(raw)
        return new if raw.nil?

        raw = JSON.parse(raw) if raw.is_a?(String)

        case raw
        when Array then new(pairs: raw.map { |p| Pair.build(p) })
        when Hash then from_expanded(raw)
        else raise(FormatError, "cannot unpack #{raw.class}")
        end
      end

      # Read the plain `{ document page => print page(s) }` Hash that the
      # requirements call for. Each entry becomes a collective pair, since one
      # DP may carry several PPs and no positional claim is being made.
      #
      # @param raw [Hash]
      # @return [PageMap]
      def from_expanded(raw)
        pairs = raw.map do |document_page, print_pages|
          labels = Array(print_pages)

          Pair.new(
            document: RangeSet.build([coerce_document_page(document_page)]),
            print: labels.empty? ? nil : RangeSet.build(labels),
            alignment: COLLECTIVE
          )
        end

        new(pairs:)
      end

      # Build from a IIIF Presentation manifest, v2 or v3. Canvases become DPs
      # and canvas labels seed PPs.
      #
      # Accepts already parsed data. Fetching is the caller's problem.
      #
      # @param manifest [Hash]
      # @return [PageMap]
      def from_iiif_manifest(manifest)
        hash = manifest.transform_keys(&:to_s)

        canvases =
          if hash['items']
            Array(hash['items']).select { |i| i.transform_keys(&:to_s)['type'].to_s == 'Canvas' }
          else
            Array(hash['sequences']).flat_map { |s| Array(s.transform_keys(&:to_s)['canvases']) }
          end

        pairs = canvases.map do |raw_canvas|
          canvas = raw_canvas.transform_keys(&:to_s)
          identifier = canvas['id'] || canvas['@id']
          label = iiif_label(canvas['label'])

          Pair.new(
            document: RangeSet.build([identifier]),
            print: label.nil? ? nil : RangeSet.build([label]),
            alignment: COLLECTIVE
          )
        end

        new(pairs:)
      end

      # Build from Biodiversity Heritage Library item metadata. Each page record
      # carries a stable identifier and structured print numbers, which is a
      # direct PP to DP source.
      #
      # The exact field spellings are not documented in this repository; verify
      # them against BHL's own current API documentation. Several spellings are
      # tolerated here so a shape change degrades rather than explodes.
      #
      # @param item [Hash]
      # @param page_url [Proc, nil] maps a page identifier to a DP; defaults to
      #   the identifier itself
      # @return [PageMap]
      def from_bhl_item(item, page_url: nil)
        hash = item.transform_keys(&:to_s)

        pairs = Array(hash['Pages'] || hash['pages']).map do |raw_page|
          page = raw_page.transform_keys(&:to_s)
          identifier = page['PageID'] || page['pageID'] || page['id']
          identifier = page_url.call(identifier) if page_url

          labels = Array(page['PageNumbers'] || page['pageNumbers']).filter_map do |raw_number|
            number = raw_number.transform_keys(&:to_s)
            value = number['Number'] || number['number']
            next if value.nil? || value.to_s.strip.empty?

            value.to_s
          end

          Pair.new(
            document: RangeSet.build([identifier]),
            print: labels.empty? ? nil : RangeSet.build(labels),
            alignment: COLLECTIVE
          )
        end

        new(pairs:)
      end

      private

      # IIIF labels are a plain string in v2 and a language map in v3.
      def iiif_label(raw)
        case raw
        when nil then nil
        when String then raw
        when Array then iiif_label(raw.first)
        when Hash then iiif_label(raw.values.first)
        else raw.to_s
        end
      end

      def coerce_document_page(value)
        return value if value.is_a?(Integer)
        return Integer(value) if value.is_a?(String) && /\A-?\d+\z/.match?(value)

        value
      end
    end

    # @param pairs [Array<Pair>] order is meaningful; a later pair wins for the
    #   document pages it names
    def initialize(pairs: [])
      @pairs = pairs
    end

    # The compact canonical form, ready for `to_json`.
    #
    # @return [Array<Hash>]
    def pack
      pairs.map(&:as_json)
    end

    def to_json(*args)
      pack.to_json(*args)
    end

    # The expanded `{ document page => [labels] }` view. `pack` is the canonical
    # form; this is the readable one.
    #
    # @return [Hash]
    def to_h
      document_pages.each_with_object({}) do |dp, out|
        out[dp] = print_page(dp).map(&:label)
      end
    end

    def empty?
      pairs.empty?
    end

    # @return [Array<Integer, String>] every distinct DP, integers ascending
    #   first, then non integers in order of first appearance
    def document_pages
      index.keys
    end

    # Every distinct printed page, sorted. A label appearing on several document
    # pages appears here once, because it is one printed page.
    #
    # @return [Array<PrintPage>]
    def print_pages
      @print_pages ||= index.values.flatten.uniq.sort
    end

    # @param document_page [Integer, String]
    # @return [Array<PrintPage>] empty when unknown, never nil
    def print_page(document_page)
      index.fetch(normalize_document_page(document_page), [])
    end

    # Every document page bearing this label. A label printed on more than one
    # document page is one printed page, so all of them come back.
    #
    # @param print_page [String, Integer, PrintPage]
    # @return [Array<Integer, String>] empty when unknown, never nil
    def document_page(print_page)
      (print_index[lookup_key(print_page)] || []).uniq
    end

    # @return [String, nil] the first label on the page, a convenience over
    #   `print_page`
    def label_for(document_page)
      print_page(document_page).first&.label
    end

    # @yieldparam document_page [Integer, String]
    # @yieldparam print_pages [Array<PrintPage>]
    def each_page
      return enum_for(:each_page) unless block_given?

      index.each { |dp, pps| yield(dp, pps) }
    end

    # The total number of pages, preferring a complete document side range, then
    # a complete print side range, then the count of distinct document pages.
    # Nil only when the map is empty.
    #
    # @return [Integer, nil]
    def total_pages
      dps = document_pages
      return nil if dps.empty?

      integers = dps.select { |dp| dp.is_a?(Integer) }.sort

      if integers.size == dps.size && integers.first == 1 &&
          integers.last == integers.size
        return integers.size
      end

      complete_print_run || dps.size
    end

    # @return [Boolean] true when both sides cover the same number of pages
    def mapped?
      !document_pages.empty? && document_pages.size == print_pages.size
    end

    # Missing pages inside the envelope of what is mapped: integers absent from
    # the document side, and integer labels absent from the print side. String
    # labels have no order to be missing from, so they are not considered.
    #
    # @return [Hash]
    def gaps
      { 'document' => missing_integers(document_pages.select { |dp| dp.is_a?(Integer) }),
        'print' => missing_integers(print_pages.filter_map(&:numeric_value)) }
    end

    # Document pages claimed by more than one pair. Not an error — the later
    # pair simply wins — but overlap is usually unintended, so it is worth
    # being able to ask.
    #
    # @return [Array<Integer, String>]
    def conflicts
      seen = Hash.new(0)

      pairs.each do |pair|
        pair.document_pages.uniq.each { |dp| seen[dp] += 1 }
      end

      seen.select { |_, count| count > 1 }.keys
    end

    # Assign print pages to a document page, replacing whatever was there.
    # Appended, because a later pair wins.
    #
    # Any earlier pair naming this document page and nothing else is dropped: it
    # has been superseded in full, and keeping it would only pad the packed form.
    # A pair covering a wider span stays, still governing its other pages.
    #
    # @return [self]
    def set(document_page, print_pages)
      labels = Array(print_pages)
      target = normalize_document_page(document_page)

      @pairs = pairs.reject { |pair| pair.document_pages == [target] }

      @pairs << Pair.new(
        document: RangeSet.build([target]),
        print: labels.empty? ? nil : RangeSet.build(labels),
        alignment: COLLECTIVE
      )

      reset!
      self
    end

    # Shift every integer print page by `offset`. The document side is untouched
    # and so is every label that is not an integer, roman numerals included.
    #
    # @return [PageMap] a new map; the receiver is unchanged
    def shift(offset)
      self.class.new(pairs: pairs.map { |p| shift_pair(p, offset) })
    end

    # A flat projection for a host to index however it likes. Deliberately
    # generous: it may produce false positives, it must never produce a false
    # negative, and it is never a source of truth.
    #
    # @return [Array<String>]
    def page_tokens
      print_pages.map(&:normalized_label).uniq.sort
    end

    def ==(other)
      other.is_a?(PageMap) && pack == other.pack
    end

    def inspect
      "#<#{self.class.name} pairs=#{pairs.size} pages=#{document_pages.size}>"
    end

    private

    # Built once, memoized, never persisted.
    #
    # Pairs are applied in order and a later one wins: it clears the document
    # pages it names before assigning. A document page carrying several labels
    # says so within a single pair, not across two.
    def index
      @index ||=
        begin
          built = {}

          pairs.each do |pair|
            pair.document_pages.uniq.each { |dp| built[dp] = [] }
            pair.each_mapping { |dp, pp| built[dp] << pp if pp }
          end

          sort_index(built)
        end
    end

    def print_index
      @print_index ||=
        index.each_with_object({}) do |(dp, pps), out|
          pps.each { |pp| (out[pp.normalized_label] ||= []) << dp }
        end
    end

    def reset!
      @index = nil
      @print_index = nil
      @print_pages = nil
    end

    def sort_index(built)
      integers, others = built.keys.partition { |dp| dp.is_a?(Integer) }

      (integers.sort + others).each_with_object({}) do |dp, out|
        out[dp] = built[dp]
      end
    end

    def normalize_document_page(value)
      return value if value.is_a?(Integer)
      return Integer(value) if value.is_a?(String) && /\A-?\d+\z/.match?(value)

      value
    end

    def lookup_key(value)
      return value.normalized_label if value.is_a?(PrintPage)

      PrintPage.new(value).normalized_label
    end

    def missing_integers(values)
      sorted = values.uniq.sort
      return [] if sorted.size < 2

      (sorted.first..sorted.last).to_a - sorted
    end

    # The count of printed pages when every one of them is an integer and they
    # form a complete contiguous run. Nil when anything is ragged or textual.
    def complete_print_run
      pages = print_pages
      return nil if pages.empty?

      values = pages.filter_map(&:numeric_value)
      return nil unless values.size == pages.size
      return nil unless values.max - values.min + 1 == values.size

      values.size
    end

    def shift_pair(pair, offset)
      return pair if pair.unmapped?

      shifted = pair.print.members.map { |segment| shift_segment(segment, offset) }

      Pair.new(
        document: pair.document,
        print: RangeSet.new(shifted),
        alignment: pair.alignment
      )
    end

    # Only integers shift. A roman range generates strings, and strings have no
    # arithmetic.
    def shift_segment(segment, offset)
      case segment.type
      when :integer
        Segment.new(type: :integer, from: segment.from + offset, to: segment.to + offset, step: segment.step)
      when :template
        Segment.new(type: :template, template: segment.template, from: segment.from + offset, to: segment.to + offset)
      when :literal
        page = PrintPage.new(segment.value)
        return segment unless page.integer?

        value = page.numeric_value + offset
        Segment.new(type: :literal, value: segment.value.is_a?(Integer) ? value : value.to_s)
      else
        segment
      end
    end
  end
end
