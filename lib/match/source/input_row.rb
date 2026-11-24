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

      # The year in a verbatim citation, optionally wrapped in parentheses.
      VERBATIM_YEAR_PATTERN =
        /\(?\s*#{::Utilities::Bibliography::YEAR_WITH_SUFFIX}\s*\)?/

      # A DOI in a verbatim citation, without punctuation that ends it.
      DOI_PATTERN = %r{\b(10\.\d{4,9}/\S+?)[.,;]?(?=\s|\z)}

      # What a DOI was written with in front of it, `(doi:`, `https://doi.org/`.
      DOI_LEAD_PATTERN =
        %r{[(\[<]?\s*(?:https?://(?:dx\.)?doi\.org/|\bdoi:?)?\s*\z}i

      attr_reader :surnames, :first_author_initials, :year, :year_suffix,
        :title, :journal, :volume, :first_page, :doi

      # @return [String, nil] for a verbatim citation, what's left once the
      #   parts that can be told apart (authors, year, DOI, volume and pages)
      #   are taken out: what may be its title and journal, not told apart,
      #   e.g. `Fleas of Indiana. J. Parasitology`. Nil when nothing is left,
      #   e.g. for `Smith 1990. 12: 5-9.`, so that title and journal aren't
      #   compared (rather than failing against what's there) and the citation
      #   isn't searched for as a whole. Nil for a row given as fields.
      attr_reader :unparsed_text

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

        author_string =
          ::Utilities::Strings.plain_text(authors) || verbatim_parts[:authors]
        @surnames = ::Utilities::AuthorNames.surnames(author_string)
        @first_author_initials =
          ::Utilities::AuthorNames.first_author_initials(author_string)

        parsed_year, parsed_suffix = parse_year(year)
        @year = parsed_year || verbatim_parts[:year]
        @year_suffix =
          parsed_year ? parsed_suffix : verbatim_parts[:year_suffix]

        @title = ::Utilities::Strings.plain_text(title)
        @journal = ::Utilities::Strings.plain_text(journal)

        parsed_volume, volume_first_page = parse_volume(volume)
        @volume = parsed_volume || verbatim_parts[:volume]
        @first_page = ::Utilities::Bibliography.first_page(pages) ||
          volume_first_page || verbatim_parts[:first_page]

        @doi = normalize_doi(doi) || verbatim_parts[:doi]
        @unparsed_text = verbatim_parts[:unparsed_text]
      end

      def empty?
        surnames.empty? && year.nil? && title.nil? && journal.nil? &&
          volume.nil? && first_page.nil? && doi.nil? &&
          unparsed_text.nil?
      end

      private

      # @return [Array] [year (Integer), suffix (String)] or [nil, nil]
      def parse_year(value)
        m = value.to_s.match(
          /\A\s*(\d{4})\s*(#{::Utilities::Bibliography::YEAR_SUFFIX})?\s*\z/o
        )
        return [nil, nil] if m.nil?

        [m[1].to_i, m[2]]
      end

      # @return [Array] [volume, first_page]
      def parse_volume(value)
        s = value.to_s.strip
        return [nil, nil] if s.empty?

        if s.match?(/\Ap{1,2}\.?\s*\d/i)
          return [nil, ::Utilities::Bibliography.first_page(s)]
        end

        volume = ::Utilities::Bibliography.volume_number(s)
        first_page = s[/:\s*(\d+)/, 1]
        [volume, first_page]
      end

      def normalize_doi(value)
        ::Identifier::Global::Doi.normalize(value.to_s).presence&.downcase
      end

      # Reads what can be told apart reliably in a verbatim citation:
      #
      #   Ritzi, C.M. (2003) Fleas of Indiana. J. Parasitology 96(2): 285-298.
      #   doi:10.1/x
      #
      #   doi            `10.1/x`, wherever it is
      #   authors        `Ritzi, C.M.`, before the year
      #   year           2003 (year_suffix nil)
      #   volume         `96` and first_page `285`, from after the year
      #   unparsed_text  `Fleas of Indiana. J. Parasitology`, see #unparsed_text
      #
      # Title and journal aren't split out: where one ends and the next begins
      # can't be told reliably (`Notes on Ctenophthalmus. II.`, `J.
      # Parasitol.`, books with no journal).
      #
      # @return [Hash] the parts found, nil values for those that aren't
      def parse_verbatim(verbatim)
        s = ::Utilities::Strings.plain_text(verbatim)
        return {} if s.nil?

        doi, s = take_doi(s)

        if (m = s.match(VERBATIM_YEAR_PATTERN))
          authors, year, year_suffix = m.pre_match, m[1].to_i, m[2]&.strip
          rest = m.post_match
        else
          rest = s
        end

        volume, first_page, rest = take_volume_and_first_page(rest)

        {
          doi:, authors:, year:, year_suffix:, volume:, first_page:,
          # Without the punctuation that separated it from the year, `(2003).`,
          # or that's left at the end, where volume and pages were.
          unparsed_text:
            rest.sub(/\A[\s.,:;)]+/, '').sub(/[\s.,:;]+\z/, '').squish.presence
        }
      end

      # @return [Array] [the DOI, lowercased, or nil; the citation without it
      #   or what it was written with]
      def take_doi(citation)
        m = citation.match(DOI_PATTERN)
        return [nil, citation] if m.nil?

        # A DOI written in brackets is read up to the next space, so it may
        # end with the closing bracket; normalize drops it.
        doi = ::Identifier::Global::Doi.normalize(m[1])
        after = m[1].delete_prefix(doi) + m.post_match
        rest = (m.pre_match.sub(DOI_LEAD_PATTERN, '') + ' ' +
          after.sub(/\A[)\]>.,;]+/, '')).squish

        [doi.downcase, rest]
      end

      # @return [Array] [volume, first page (nil when not found), text without
      #   them, the rest of a page range included]
      def take_volume_and_first_page(text)
        ::Utilities::Bibliography::VOLUME_PAGES_PATTERNS.each do |pattern|
          m = text.match(pattern)
          next if m.nil?

          after = m.post_match.sub(/\A\s*[-–—]\s*\d+/, '')
          return [*m.captures, "#{m.pre_match} #{after}"]
        end
        [nil, nil, text]
      end

    end
  end
end
