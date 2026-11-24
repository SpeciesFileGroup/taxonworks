# One row of a Source match request, normalized for comparison against
# Sources.
#
# A row may be given as structured fields (authors, year, title, journal,
# volume, pages, doi), as a single verbatim citation string, or both;
# structured fields win over anything parsed out of `verbatim`.
#
# Usage:
#   r = Match::Source::InputRow.new(
#     authors: 'Ritzi, C.M. & J.O. Whitaker, Jr.',
#     year: '2003',
#     volume: '10(2):149-158'
#   )
#   r.surnames # => ['Ritzi', 'Whitaker']
#   r.first_author_initials # => ['C', 'M']
#   r.volume # => '10'
#   r.first_page # => '149'
#
module Match
  module Source
    class InputRow

      YEAR_PATTERN = /\b(1[5-9]\d{2}|20\d{2})\s*([a-z])?\b/

      # The year in a verbatim citation, optionally wrapped in parentheses.
      VERBATIM_YEAR_PATTERN = /\(?\s*#{YEAR_PATTERN}\s*\)?/

      DOI_PATTERN = %r{\b(10\.\d{4,9}/\S+?)[.,;]?(?=\s|\z)}

      DOI_PREFIX_PATTERN = %r{\A(?:https?://(?:dx\.)?doi\.org/|doi:\s*)}i

      # What's left before a DOI once it's removed from a verbatim citation.
      DOI_LEAD_PATTERN =
        %r{[(\[<]?\s*(?:https?://(?:dx\.)?doi\.org/|\bdoi:?)?\s*\z}i

      # `96(2):285-298`, `1027: 55-63`, `, 16, 81–97`, `, 58(3), 529–536`,
      # and a single page, `, 44(3), 115.`, `, 12, p. 5`: one ending the
      # citation or followed by `.`/`;`, so `, 2, 248 pp.` and `, 12, 3 figs.`
      # aren't read as pages, nor is a list of pages, `, 25, 167,179.`
      VOLUME_PAGES_PATTERNS = [
        /\b(\d+)\s*(?:\([^)]*\))?\s*:\s*(\d+)/,
        /,\s*(\d+)\s*(?:\([^)]*\))?\s*,\s*(?:pp?\.\s*)?(\d+)\s*[-–—]\s*\d+/,
        /,\s*(\d+)\s*(?:\([^)]*\))?\s*,\s+(?:p\.\s*)?(\d+)\s*(?:[.;]|\z)/
      ].freeze

      attr_reader :surnames, :first_author_initials, :year, :year_suffix,
        :title, :journal, :volume, :first_page, :doi, :text

      # @param authors [String, nil]
      #   e.g. `Ritzi, C.M. & J.O. Whitaker, Jr.`, `Emery, Emery & Popple`
      # @param year [String, Integer, nil] e.g. `2003`, `1936a`
      # @param volume [String, nil]
      #   volume, optionally with issue and pages, e.g. `10(2):149-158`
      # @param pages [String, nil] e.g. `149-158`
      # @param verbatim [String, nil] a full citation string
      def initialize(
        authors: nil, year: nil, title: nil, journal: nil, volume: nil,
        pages: nil, doi: nil, verbatim: nil
      )
        verbatim_parts = parse_verbatim(verbatim)

        author_string = ::Utilities::Strings.plain_text(authors) || verbatim_parts[:authors]
        @surnames = ::Utilities::AuthorNames.surnames(author_string)
        @first_author_initials =
          ::Utilities::AuthorNames.first_author_initials(author_string)

        parsed_year, parsed_suffix = parse_year(year)
        @year = parsed_year || verbatim_parts[:year]
        @year_suffix = parsed_year ? parsed_suffix : verbatim_parts[:year_suffix]

        @title = ::Utilities::Strings.plain_text(title)
        @journal = ::Utilities::Strings.plain_text(journal)

        parsed_volume, volume_first_page = parse_volume(volume)
        @volume = parsed_volume || verbatim_parts[:volume]
        @first_page = Field::FirstPage.number(pages) || volume_first_page ||
          verbatim_parts[:first_page]

        @doi = normalize_doi(doi) || verbatim_parts[:doi]
        @text = verbatim_parts[:text]
      end

      # @return [String] the DOI without brackets it was written in,
      #   `(doi:10.1/x)` -> `10.1/x`, keeping balanced ones, `10.1/a(1)b`
      def self.unbracket_doi(doi)
        { ')' => '(', ']' => '[', '>' => '<' }.each do |close, open|
          while doi.end_with?(close) && doi.count(close) > doi.count(open)
            doi = doi[0..-2]
          end
        end
        doi
      end

      def empty?
        surnames.empty? && year.nil? && title.nil? && journal.nil? &&
          volume.nil? && first_page.nil? && doi.nil? && text.nil?
      end

      private

      # @return [Array] [year (Integer), suffix (String)] or [nil, nil]
      def parse_year(value)
        m = value.to_s.match(/\A\s*(\d{4})\s*([a-z])?\s*\z/)
        return [nil, nil] if m.nil?

        [m[1].to_i, m[2]]
      end

      # @return [Array] [volume, first_page]
      def parse_volume(value)
        s = value.to_s.strip
        return [nil, nil] if s.empty?

        if s.match?(/\Ap{1,2}\.?\s*\d/i)
          return [nil, Field::FirstPage.number(s)]
        end

        volume = Field::Volume.number(s)
        first_page = s[/:\s*(\d+)/, 1]
        [volume, first_page]
      end

      def normalize_doi(value)
        s = self.class.unbracket_doi(
          value.to_s.strip.sub(DOI_PREFIX_PATTERN, '')
        )
        s.empty? ? nil : s.downcase
      end

      def parse_verbatim(verbatim)
        s = ::Utilities::Strings.plain_text(verbatim)
        return {} if s.nil?

        result = {}

        if (m = s.match(DOI_PATTERN))
          doi = self.class.unbracket_doi(m[1])
          result[:doi] = doi.downcase
          rest = m[1].delete_prefix(doi) + m.post_match
          s = (m.pre_match.sub(DOI_LEAD_PATTERN, '') + ' ' +
            rest.sub(/\A[)\]>.,;]+/, '')).squish
        end

        if (m = s.match(VERBATIM_YEAR_PATTERN))
          result[:year] = m[1].to_i
          result[:year_suffix] = m[2]
          result[:authors] = m.pre_match
          rest = m.post_match
        else
          rest = s
        end

        VOLUME_PAGES_PATTERNS.each do |pattern|
          next if (m = rest.match(pattern)).nil?

          result[:volume] = m[1]
          result[:first_page] = m[2]
          break
        end

        result[:text] = rest.sub(/\A[\s.,:;)]+/, '').squish.presence
        result
      end

    end
  end
end
