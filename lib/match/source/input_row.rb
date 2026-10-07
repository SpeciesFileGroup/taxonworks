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

      # `96(2):285-298`, `1027: 55-63`, `, 16, 81–97`, `, 58(3), 529–536`
      VOLUME_PAGES_PATTERNS = [
        /\b(\d+)\s*(?:\([^)]*\))?\s*:\s*(\d+)/,
        /,\s*(\d+)\s*(?:\([^)]*\))?\s*,\s*(?:pp?\.\s*)?(\d+)\s*[-–—]\s*\d+/
      ].freeze

      AUTHOR_SEPARATOR_PATTERN = /\s*(?:&|;|\band\b|\bund\b)\s*/i

      # `R`, `g.`, `R.`, `C.M.`, `F.G.A.M.`, `J.-P.`, `J-M.`, `Y-L`, `Ch.`,
      # `KB.`
      INITIALS_PATTERN = /\A(?:
        [[:alpha:]](?:-[[:upper:]])*\.*|
        (?:[[:upper:]][[:lower:]]?\.-?)+\.*|
        [[:upper:]]{2}\.
      )\z/x

      NAME_SUFFIX_PATTERN = /\A(?:jr|sr|ii|iii|iv)\.?\z/i

      attr_reader :surnames, :year, :year_suffix, :title, :journal, :volume,
        :first_page, :doi, :text

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

        @surnames = authors.present? ?
          self.class.surnames(authors) : verbatim_parts[:surnames]

        parsed_year, parsed_suffix = parse_year(year)
        @year = parsed_year || verbatim_parts[:year]
        @year_suffix = parsed_year ? parsed_suffix : verbatim_parts[:year_suffix]

        @title = clean(title)
        @journal = clean(journal)

        parsed_volume, volume_first_page = parse_volume(volume)
        @volume = parsed_volume || verbatim_parts[:volume]
        @first_page = parse_first_page(pages) || volume_first_page ||
          verbatim_parts[:first_page]

        @doi = normalize_doi(doi) || verbatim_parts[:doi]
        @text = verbatim_parts[:text]
      end

      def empty?
        surnames.empty? && year.nil? && title.nil? && journal.nil? &&
          volume.nil? && first_page.nil? && doi.nil? && text.nil?
      end

      # @return [Array<String>]
      #   surnames in author order, initials and name suffixes removed
      def self.surnames(author_string)
        s = author_string.to_s
          .gsub(/<[^>]*>/, ' ')
          .gsub(/\([^)]*\)/, ' ')
          .gsub(/\bet\.?\s*al\b\.?/i, ' ')
          .gsub(%r{/\s*\d{4}\b}, ' ')

        s.split(AUTHOR_SEPARATOR_PATTERN).flat_map { |chunk|
          chunk.split(',').filter_map { |token| surname_from_token(token) }
        }
      end

      # @return [String] for comparing names: no diacritics, case, spaces, or
      #   punctuation
      def self.fold(string)
        I18n.transliterate(string.to_s).downcase.gsub(/[^a-z]/, '')
      end

      def self.surname_from_token(token)
        words = token
          .sub(/\A[^[:alpha:]]+/, '')
          .split(/\s+|(?<=\.)(?=[[:alpha:]])/)
          .map(&:strip)
          .reject { |w|
            !w.match?(/[[:alpha:]]/) || w.match?(INITIALS_PATTERN) ||
              w.match?(NAME_SUFFIX_PATTERN)
          }

        name = words.join(' ').sub(/[.\s]+\z/, '')
        name.presence
      end

      private_class_method :surname_from_token

      private

      def clean(string)
        string.to_s.gsub(/<[^>]*>/, ' ').squish.presence
      end

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
          return [nil, parse_first_page(s)]
        end

        volume = s[/\A([^\s(:]+)/, 1]
        first_page = s[/:\s*(\d+)/, 1]
        [volume, first_page]
      end

      def parse_first_page(value)
        value.to_s[/\d+/]
      end

      def normalize_doi(value)
        s = value.to_s.strip.sub(DOI_PREFIX_PATTERN, '')
        s.empty? ? nil : s.downcase
      end

      def parse_verbatim(verbatim)
        s = clean(verbatim)
        return { surnames: [] } if s.nil?

        result = {}

        if (m = s.match(DOI_PATTERN))
          result[:doi] = m[1].downcase
          s = (m.pre_match + ' ' + m.post_match).sub(/\bdoi:?\s*\z/i, '')
            .squish
        end

        if (m = s.match(VERBATIM_YEAR_PATTERN))
          result[:year] = m[1].to_i
          result[:year_suffix] = m[2]
          result[:surnames] = self.class.surnames(m.pre_match)
          rest = m.post_match
        else
          result[:surnames] = []
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
