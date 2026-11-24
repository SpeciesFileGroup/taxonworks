# Author name strings: split into surnames, and folded for comparison.
#
# Usage:
#   Utilities::AuthorNames.surnames('Ritzi, C.M. & J.O. Whitaker, Jr.')
#     # => ['Ritzi', 'Whitaker']
#   Utilities::AuthorNames.first_author_initials('Smit, F.G.A.M.')
#     # => ['F', 'G', 'A', 'M']
#   Utilities::AuthorNames.fold('Creão-Duarte') # => 'creaoduarte'
#   Utilities::AuthorNames.authorship_key('(Walker, 1851)')
#     # => { surnames: ['walker'], year: 1851, parenthesized: true }
module Utilities::AuthorNames

  AUTHOR_SEPARATOR_PATTERN = /\s*(?:&|;|\band\b|\bund\b|\bet\b)\s*/i

  # `R`, `g.`, `R.`, `C.M.`, `F.G.A.M.`, `J.-P.`, `J-M.`, `Y-L`, `Ch.`,
  # `KB.`, `G.-qiu`
  INITIALS_PATTERN = /\A(?:
    [[:alpha:]](?:-[[:upper:]])*\.*|
    (?:[[:upper:]][[:lower:]]?\.-?)+\.*|
    [[:upper:]]{2}\.|
    [[:upper:]]\.-[[:lower:]]+
  )\z/x

  NAME_SUFFIX_PATTERN = /\A(?:jr|sr|ii|iii|iv)\.?\z/i

  # Surname particles, as written after the initials in `León, J.H.de`.
  PARTICLES = %w{
    d da das de del della den der des di do dos du la le ten ter van von zu
  }.to_set.freeze

  # @return [Array<String>]
  #   surnames in author order, initials and name suffixes removed; a
  #   particle written after the initials (`León, J.H.de`) is put back in
  #   front of its surname (`de León`)
  def self.surnames(author_string)
    author_chunks(author_string).flat_map { |chunk|
      chunk.split(',').each_with_object([]) { |token, names|
        name = surname_from_token(token)
        next if name.nil?

        particles = names.any? && surname_particles(token)
        if !particles
          names << name
        elsif particles.empty? # a given name's particle, `M.dos S.`
          next
        elsif !names[-1].downcase.start_with?("#{particles.downcase} ")
          # (sometimes written twice: `de Mello, F.A.de`)
          names[-1] = "#{particles} #{names[-1]}"
        end
      }
    }
  end

  # @param surname [String, nil] one surname, e.g. from .surnames
  # @return [Array<String>] its words, particles aside: `García López` =>
  #   ['García', 'López'], `van der Merwe` => ['Merwe']
  def self.surname_words(surname)
    surname.to_s.split.reject { |w| PARTICLES.include?(w.downcase) }
  end

  # @param given_names [String, nil]
  #   e.g. `F.G.A.M.`, `Franciscus Gerardus Albertus Maria`, `J.-P.`
  # @return [Array<String>] the initial of each given name, upcased, without
  #   diacritics, e.g. ['F', 'G', 'A', 'M']
  def self.initials(given_names)
    given_names.to_s.split(/[\s.\-]+/).reject(&:empty?).flat_map { |part|
      # `KB` is two initials, `Ch` (and `Charles`) one.
      letters = part.match?(/\A[[:upper:]]{2,3}\z/) ? part.chars : [part[0]]
      letters.map { |l| I18n.transliterate(l).upcase }
    }
  end

  # Only initials written next to the first author's surname count:
  # `Smit, F.G.A.M.`, `Smit F.G.A.M.`, `F.G.A.M. Smit`. Full given names
  # aren't recognized, since in a comma separated list they can't be told
  # apart from other authors' surnames (`Huang, Liu, Chen`).
  #
  # @param author_string [String, nil]
  # @return [Array<String>] the first author's initials, see .initials;
  #   empty when there are none or they're ambiguous
  def self.first_author_initials(author_string)
    chunk = author_chunks(author_string).first
    return [] if chunk.nil?

    tokens = chunk.split(',').map(&:strip).reject(&:empty?)
    i = tokens.index { |token| surname_from_token(token) }
    return [] if i.nil?

    words = initials_words(token_words(tokens[i]))
    if words.empty? && tokens[i + 1]
      following = token_words(tokens[i + 1])
      following_initials = initials_words(following)
      if (following - following_initials).all? { |w| particle?(w) }
        words = following_initials
      end
    end

    initials(words.join(' '))
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
  #   * parenthesized - sensu ICZN;
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

  # @return [Array<String>] the authors' part of author_string, split on
  #   author separators (`&`, `and`, ...); one chunk may still hold several
  #   comma separated authors
  def self.author_chunks(author_string)
    author_string.to_s
      .gsub(/<[^>]*>/, ' ') # remove <...>
      .gsub(/\([^)]*\)/, ' ') # remove (...)
      .gsub(/\bet\.?\s*al\b\.?/i, ' ') # remove 'et al'
      .gsub(%r{/\s*\d{4}\b}, ' ') # remove years
      .split(AUTHOR_SEPARATOR_PATTERN)
      .select { |chunk| chunk.match?(/[[:alpha:]]/) }
  end

  # @return [Array<String>] the words of one comma separated token, with any
  #   leading junk and words without letters removed
  def self.token_words(token)
    token
      .sub(/\A[^[:alpha:]]+/, '') # remove leading junk
      # The second pattern here matches the position between '.' and any letter,
      # like 'KB.Agwanda' (uncommon).
      .split(/\s+|(?<=\.)(?=[[:alpha:]])/)
      .map(&:strip)
      .select { |w| w.match?(/[[:alpha:]]/) }
  end

  def self.initials_words(words)
    words.select { |w| w.match?(INITIALS_PATTERN) }
  end

  def self.particle?(word)
    PARTICLES.include?(word)
  end

  # A token of initials and particles only follows a surname: `León,
  # J.H.de`, `Walt, A.van der`, `Schrank, F.von P.`. Particles at its end
  # are the surname's (`de León`, `van der Walt`); any before an initial are
  # a given name's (Franz von Paula Schrank).
  #
  # @return [String, nil] the surname's particles, '' when there are none;
  #   nil when token isn't initials and particles only
  def self.surname_particles(token)
    words = token_words(token)
    initials = initials_words(words)
    rest = words - initials
    return nil if initials.empty? || rest.empty?
    return nil if !rest.all? { |w| particle?(w) }

    words.reverse.take_while { |w| particle?(w) }.reverse.join(' ')
  end

  def self.surname_from_token(token)
    words = token_words(token).reject { |w|
      w.match?(INITIALS_PATTERN) || w.match?(NAME_SUFFIX_PATTERN)
    }

    name = words.join(' ').sub(/[.\s]+\z/, '')
    name.presence
  end

  private_class_method :author_chunks, :token_words, :initials_words,
    :particle?, :surname_particles, :surname_from_token

end
