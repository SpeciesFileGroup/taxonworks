# Pieces of bibliographic citation text, as written: years, volumes, pages.
# For authors see Utilities::AuthorNames; for DOIs Identifier::Global::Doi.
#
# Usage:
#   '1936a'[Utilities::Bibliography::YEAR_WITH_SUFFIX] # => '1936a'
#   Utilities::Bibliography.volume_number('Vol. 10(2):149-158') # => '10'
#   Utilities::Bibliography.first_page('149-158') # => '149'
module Utilities::Bibliography

  # A publication year, 1500 to 2099.
  YEAR = /1[5-9]\d{2}|20\d{2}/

  # A year with an optional suffix: captures the year and the suffix, `1936a`,
  # `1936 a`.
  YEAR_WITH_SUFFIX = /\b(#{YEAR})\s*([a-z])?\b/

  # A volume's label, `Vol. 10`, `Volume 10`.
  VOLUME_LABEL = /\Avol(?:ume)?\.?\s*/i

  # A volume and its first page in a citation, captured in that order:
  # `96(2):285-298`, `1027: 55-63`, `, 16, 81–97`, `, 58(3), 529–536`, and a
  # single page, `, 44(3), 115.`, `, 12, p. 5`: one ending the citation or
  # followed by `.`/`;`, so `, 2, 248 pp.` and `, 12, 3 figs.` aren't read as
  # pages, nor is a list of pages, `, 25, 167,179.`
  VOLUME_PAGES_PATTERNS = [
    /\b(\d+)\s*(?:\([^)]*\))?\s*:\s*(\d+)/,
    /,\s*(\d+)\s*(?:\([^)]*\))?\s*,\s*(?:pp?\.\s*)?(\d+)\s*[-–—]\s*\d+/,
    /,\s*(\d+)\s*(?:\([^)]*\))?\s*,\s+(?:p\.\s*)?(\d+)\s*(?:[.;]|\z)/
  ].freeze

  # @param value [String, nil] a volume, optionally labelled and followed by
  #   issue and pages, e.g. `10(2):149-158`, `65(1)`, `Vol. 10 (2)`
  # @return [String, nil] the volume alone, e.g. `10`
  def self.volume_number(value)
    value.to_s.strip.sub(VOLUME_LABEL, '')[/\A([^\s(:,;]+)/, 1]
  end

  # The first number in pages: `149` of `149-158`, `5` of `p. 5`. A page
  # count reads as a page, `248` of `xii + 248 pp.`.
  # @param value [String, nil]
  # @return [String, nil]
  def self.first_page(value)
    value.to_s[/\d+/]
  end

end
