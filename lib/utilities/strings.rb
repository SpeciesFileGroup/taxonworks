# Methods that recieve or generate a String. This methods in this library should be completely independant (i.e. ultimately gemifiable) from TaxonWorks.
module Utilities::Strings

  # return [String, nil]
  #   stub a string of a certain length
  def self.random_string(string_length)
    return nil if string_length.to_i == 0
    ('a'..'z').to_a.shuffle[0, string_length].join
  end

  # @return [String, nil]
  #   strips space, leaves internal whitespace as is, returns nil if nothing is left
  def self.nil_strip(string) # string should have content or be empty
    if !string.nil?
      string.strip!
      string = nil if string == ''
    end
    string
  end

  # @return [String, nil]
  #  strips pre/post fixed space and condenses internal spaces, but returns nil (not empty string) if nothing is left
  def self.nil_squish_strip(string)
    if !string.nil?
      string.squish!
      string = nil if string == ''
    end
    string
  end

  def self.generate_md5(text)
    return nil if text.blank?
    text = text.downcase.gsub(/[\s\.,;:\?!]*/, '')
    Digest::MD5.hexdigest(text)
  end

  def self.increment_contained_integer(string)
    string =~ /([^\d]*)(\d+)([^\d]*)/
    a, b, c = $1, $2, $3
    return false if b.nil?
    [a,(b.to_i + 1), c].compact.join
  end

  # Adds a second single quote to escape apostrophe in SQL query strings
  def self.escape_single_quote(string)
    return nil if string.blank?
    string.gsub("'", "''")
  end

  # @return [Boolean]
  #   whether the string is an integer (positive or negative)
  # see http://stackoverflow.com/questions/1235863/test-if-a-string-is-basically-an-integer-in-quotes-using-ruby
  # Note:  Might checkout CSV::Converters constants to see how they handle this
  def self.is_i?(string)
    /\A[-+]?\d+\z/ === string
  end

  # @return [String, param]
  #   the goal is to sanitizie an individual string such that it is usable in *TAB* delimited, UTF-8, column.  See Download
  #   TODO: Likely need to handle quotes
  def self.sanitize_for_csv(string)
    return string if string.blank?
    string.to_s.gsub(/\n|\t/, ' ') 
  end

  # @return [String]
  #   return nil if content.nil?, else wrap and return string if provided
  def self.nil_wrap(pre = nil, content = nil, post = nil)
    return nil if content.blank?
    [pre, content, post].compact.join.html_safe
  end



end

