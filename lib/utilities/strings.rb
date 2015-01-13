module Utilities::Strings

  def self.random_string(string_length)
    return nil if string_length.to_i == 0
    ('a'..'z').to_a.shuffle[0, string_length].join
  end

  # ! NICE!
  def self.random_taxon_name
    'Aus bus'
  end

  # Strips space, leaves internal widespace as is
  def self.nil_strip(string) # string should have content or be empty
    if !string.nil?
      string.strip!
      string = nil if string == ''
    end
    string
  end

  # Strips space both condenses space
  def self.nil_squish_strip(string)
    if !string.nil?
      string.squish!
      string = nil if string == ''
    end
    string
  end

  def self.generate_md5(text)
    return nil if text.blank?
    Digest::MD5.hexdigest(text.gsub(/\s*/, '').downcase)
  end

  def self.increment_contained_integer(string)
    string =~ /([^\d]*)(\d+)([^\d]*)/
    a, b, c = $1, $2, $3
    return false if b.nil?
    [a,(b.to_i + 1), c].compact.join
  end

  # adds a second single quote to escape apostrophe in SQL query strings
  def self.escape_single_quote(string)
    return nil if string.blank?
    string.gsub("'", "''")
  end
end

