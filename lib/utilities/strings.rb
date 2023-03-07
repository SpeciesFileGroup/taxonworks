# Methods that recieve or generate a String. This methods in this library should be completely independant (i.e. ultimately gemifiable) from TaxonWorks.
module Utilities::Strings

  # @return String, nil
  #   replace <br>, <i>, <b> tags with their asciidoc equivalents
  def self.asciify(string)
    return nil if string.to_s.length == 0

    string.gsub!(/<br>/, "\n")
    string.gsub!(/<i>|<\/i>/, "_")
    string.gsub!(/<b>|<\/b>/, "**")
    string
  end

  def self.linearize(string, separator = ' | ')
    return nil if string.to_s.length == 0
    string.gsub(/\n|(\r\n)/, separator)
  end

  # @return String,nil
  #   the string preceeded with "a" or "an"
  def self.a_label(string)
    return nil if string.to_s.length == 0
    (string =~ /\A[aeiou]/i ? 'an ' : 'a ') + string
  end

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
  def self.nil_strip(string) # string should have content or be empty
    a = string.dup
    if !a.nil?
      a.strip!
      a = nil if a == ''
    end
    a
  end

  # @param [String] string
  # @return [String, nil]
  #  strips pre/post fixed space and condenses internal spaces, and also  but returns nil (not empty string) if nothing is left
  def self.nil_squish_strip(string)
    a = string.dup
    if !a.nil?
      a.delete("\u0000")
      a.squish!
      a = nil if a == ''
    end
    a
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
  # Allows '02', but treated as OK as 02.to_i returns 2
  def self.is_i?(string)
    /\A[-+]?\d+\z/ === string
  end

  # @param [String] string
  # @return [String, param]
  #   the goal is to sanitizie an individual string such that it is usable in *TAB* delimited, UTF-8, column.  See Download
  #   TODO: Likely need to handle quotes, and write better UTF compliancy tests
  #   ~~ Technically \n is allowed!
  def self.sanitize_for_csv(string)
    a = string.dup
    return a if a.blank? # TODO: .blank is Rails, not OK here
    a.to_s.gsub(/\n|\t/, ' ')
  end

  # @param [String] pre
  # @param [String] content
  # @param [String] post
  # @return [String, nil]
  #   return nil if content.nil?, else wrap and return string if provided
  def self.nil_wrap(pre = nil, content = nil, post = nil)
    return nil if content.blank?
    [pre, content, post].compact.join
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
  # #alphanumeric allows searches by page number, year, etc.
  def self.alphabetic_strings(string)
    return [] if string.nil? || string.length == 0
    string.split(/[^[[:word:]]]+/).select { |b| !(b =~ /\d/) }.reject { |b| b.empty? }
  end

  # alphanumeric allows searches by page number, year, etc.
  def self.alphanumeric_strings(string)
    return [] if string.nil? || string.length == 0
    string.split(/[^[[:word:]]]+/).reject { |b| b.empty? }
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

  # @param [String] string
  # @return [Integer, nil]
  #   return an integer if and only if the string is a single integer,
  #   otherwise nil
  def self.only_integer(string)
    if is_i?(string)
      string.to_i
    else
      nil
    end
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
    return [] if (authorship = authorship.to_s.strip).empty?

    year_match = /(,|\s)\s*(?<year>\d+)(?<paren>\))?$/.match(authorship)
    author_name = "#{authorship[..(year_match&.offset(0)&.first || 0)-1]}#{year_match&.[](:paren)}"

    [author_name, year_match&.[](:year)]
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

