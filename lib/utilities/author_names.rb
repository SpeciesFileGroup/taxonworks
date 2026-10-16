# Author name strings: split into surnames, and folded for comparison.
#
# Usage:
#   Utilities::AuthorNames.surnames('Ritzi, C.M. & J.O. Whitaker, Jr.')
#     # => ['Ritzi', 'Whitaker']
#   Utilities::AuthorNames.fold('Creão-Duarte') # => 'creaoduarte'
#   Utilities::AuthorNames.authorship_key('(Walker, 1851)')
#     # => { surnames: ['walker'], year: 1851, parenthesized: true }
module Utilities::AuthorNames

  AUTHOR_SEPARATOR_PATTERN = /\s*(?:&|;|\band\b|\bund\b)\s*/i

  # `R`, `g.`, `R.`, `C.M.`, `F.G.A.M.`, `J.-P.`, `J-M.`, `Y-L`, `Ch.`,
  # `KB.`
  INITIALS_PATTERN = /\A(?:
    [[:alpha:]](?:-[[:upper:]])*\.*|
    (?:[[:upper:]][[:lower:]]?\.-?)+\.*|
    [[:upper:]]{2}\.
  )\z/x

  NAME_SUFFIX_PATTERN = /\A(?:jr|sr|ii|iii|iv)\.?\z/i

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

  YEAR_PATTERN = /\b(1[5-9]\d{2}|20\d{2})\b/

  # The comparison key of a taxon name's authorship string, e.g. TaxonWorks
  # #cached_author_year or CoL's #authorship:
  #   * surnames - folded (.fold), in order
  #   * year - the name's own: a "non Author, year" (homonym) suffix is
  #     dropped first
  #   * parenthesized - ICZN parentheses (no longer in its original genus);
  #     sources may add them by their own placement, so compare with and
  #     without
  # nil when either surnames or year can't be found (e.g. "Lam.") - an
  # incomplete key compares with nothing.
  #
  # @param authorship [String, nil]
  #   e.g. "(Walker, 1851)", "Melichar, 1898 non Walker, 1851"
  # @return [Hash, nil] { surnames: Array<String>, year: Integer,
  #   parenthesized: Boolean }
  def self.authorship_key(authorship)
    s = authorship.to_s.sub(/\s+non\s.*\z/i, '').squish
    year = s.scan(YEAR_PATTERN).last&.first&.to_i
    surnames = surnames(s.delete('()').gsub(YEAR_PATTERN, ''))
      .map { |surname| fold(surname) }
      .reject(&:empty?)
    return nil if year.nil? || surnames.empty?

    { surnames:, year:, parenthesized: s.start_with?('(') }
  end

  # @param a [Hash, nil] an .authorship_key
  # @param b [Hash, nil] an .authorship_key
  # @param parentheses [Boolean] whether parenthesized must agree too
  # @return [Boolean] false when either key is nil
  def self.same_authorship?(a, b, parentheses: false)
    return false if a.nil? || b.nil?

    a[:surnames] == b[:surnames] && a[:year] == b[:year] &&
      (!parentheses || a[:parenthesized] == b[:parenthesized])
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

end
