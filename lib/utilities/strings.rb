# Methods that recieve or generate a String. This methods in this library should be completely independant (i.e. ultimately gemifiable) from TaxonWorks.
module Utilities::Strings

  # @param [Integer] string_length
  # @return [String, nil]
  #   stub a string of a certain length
  def self.random_string(string_length)
    return nil if string_length.to_i == 0
    ('a'..'z').to_a.shuffle[0, string_length].join
  end

  # @param [String] string
  # @return [String, nil]
  #   strips space, leaves internal whitespace as is, returns nil if nothing is left
  def self.nil_strip(string)
    # string should have content or be empty
    if !string.nil?
      string.strip!
      string = nil if string == ''
    end
    string
  end

  # @param [String] string
  # @return [String, nil]
  #  strips pre/post fixed space and condenses internal spaces, but returns nil (not empty string) if nothing is left
  def self.nil_squish_strip(string)
    if !string.nil?
      string.squish!
      string = nil if string == ''
    end
    string
  end

  # @param [String] text
  # @return [Digest::MD5]
  def self.generate_md5(text)
    return nil if text.blank?
    text = text.downcase.gsub(/[\s\.,;:\?!]*/, '')
    Digest::MD5.hexdigest(text)
  end

  # @param [String] string
  # @return [String, Boolean]
  #   increments the *first* integer encountered in the string, wrapping it
  #   in *only* the immediate non integer strings before and after (see tests).
  #   Returns false if no number is found
  def self.increment_contained_integer(string)
    string =~ /([^\d]*)(\d+)([^\d]*)/
    a, b, c = $1, $2, $3
    return false if b.nil?
    [a, (b.to_i + 1), c].compact.join
  end

  # Adds a second single quote to escape apostrophe in SQL query strings
  # @param [String] string
  # @return [String]
  def self.escape_single_quote(string)
    return nil if string.blank?
    string.gsub("'", "''")
  end

  # @param [String] string
  # @return [Boolean]
  #   whether the string is an integer (positive or negative)
  # see http://stackoverflow.com/questions/1235863/test-if-a-string-is-basically-an-integer-in-quotes-using-ruby
  # Note:  Might checkout CSV::Converters constants to see how they handle this
  # Allows '02' ... hmm
  def self.is_i?(string)
    /\A[-+]?\d+\z/ === string
  end

  # @param [String] string
  # @return [String, param]
  #   the goal is to sanitizie an individual string such that it is usable in *TAB* delimited, UTF-8, column.  See Download
  #   TODO: Likely need to handle quotes, and write better UTF compliancy tests
  #   ~~ Technically \n is allowed!
  def self.sanitize_for_csv(string)
    return string if string.blank?
    string.to_s.gsub(/\n|\t/, ' ')
  end

  #   return nil if content.nil?, else wrap and return string if provided
  # @param [String] pre
  # @param [String] content
  # @param [String] post
  # @return [String]
  def self.nil_wrap(pre = nil, content = nil, post = nil)
    return nil if content.blank?
    [pre, content, post].compact.join.html_safe
  end

  # @param last_names [Array]
  # @return [String, nil]
  # TODO: DEPRECATE (doesn't belong here because to_sentence is Rails?
  def self.authorship_sentence(last_names = [])
    return nil if last_names.empty?
    last_names.to_sentence(two_words_connector: ' & ', last_word_connector: ' & ')
  end

  # Splits a string on special characters, returning an array of the strings that do not contain digits.
  #
  # It splits on accent characters, and does not split on underscores. The method is used for building wildcard searches,
  # so splitting on accents creates pseudo accent insensitivity in searches.
  #
  # @param string [String]
  # @return [Array]
  #   whitespace and special character split, then any string containing a digit eliminated
  def self.alphabetic_strings(string)
    return [] if string.nil? || string.length == 0
    string.split(/\W/).select { |b| !(b =~ /\d/) }.reject { |b| b.empty? }
  end

  # @param string [String]
  # @return [String, false]
  #   !! this is a bad sign, you should know your encoding *before* it gets to needing this
  def self.encode_with_utf8(string)
    return false if string.nil?
    if Encoding.compatible?('test'.encode(Encoding::UTF_8), string)
      string.force_encoding(Encoding::UTF_8)
    else
      false
    end
  end

  # @return [Array]
  def self.years(string)
    return [] if string.nil?
    string.scan(/\d{4}/).to_a.uniq
  end

  # @return [String, nil]
  #   the immediately following letter recognized as coming directly past the first year
  #     `Smith, 1920a. ... ` returns `a`
  def self.year_letter(string)
    string.match(/\d{4}([a-zAZ]+)/).to_a.last
  end

  # Get numbers separated by spaces from a string
  # @param [String] string
  # @return [Array<String>]
  #   of strings representing integers
  def self.integers(string)
    return [] if string.nil? || string.length == 0
    string.split(/\s+/).select { |t| is_i?(t) }
  end

  # @return [Boolean]
  #   true if the query string only contains integers separated by whitespace
  def self.only_integers?(string)
    !(string =~ /[^\d\s]/i) && !integers(string).empty?
  end

  # Parse a scientificAuthorship field to extract author and year information.
  #
  # If the format matches ICZN, adds parentheses around author name (if detected)
  # @param [String] authorship
  # @return [Array] [author_name, year]
  def self.parse_authorship(authorship)
    if (authorship_matchdata = authorship.match(/\(?(?<author>.+?),? (?<year>\d{4})?\)?/))

      author_name = authorship_matchdata[:author]
      year = authorship_matchdata[:year]

      # author name should be wrapped in parentheses if the verbatim authorship was
      if authorship.start_with?('(') and authorship.end_with?(')')
        author_name = '(' + author_name + ')'
      end

    else
      # Fall back to simple name + date parsing
      author_name = verbatim_author(authorship)
      year = year_of_publication(authorship)
    end

    [author_name, year]
  end

  # @param [String] author_year
  # @return [String, nil]
  def self.year_of_publication(author_year)
    return nil if author_year.to_s.strip.empty?   # alternative to .blank?
    split_author_year = author_year.split(' ')
    year = split_author_year[split_author_year.length - 1]
    # try matching last element first, otherwise scan entire string for year
    # Maybe we don't need regex match and can use years(author_year) exclusively?
    year =~ /\A\d+\z/ ? year : years(author_year).last.to_s
  end

  # @param [String] author_year_string
  # @return [String, nil]
  def self.verbatim_author(author_year_string)
    return nil if author_year_string.to_s.strip.empty?  # alternative to .blank?
    author_end_index = author_year_string.rindex(' ')
    author_end_index ||= author_year_string.length
    author_year_string[0...author_end_index]
  end

end

