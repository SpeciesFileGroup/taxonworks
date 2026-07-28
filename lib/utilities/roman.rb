module Utilities

  # Conversion between integers and roman numerals.
  #
  # This module was substantially authored by Claude.
  #
  # Only canonical forms are recognized: "iv" is four, "iiii" is not. Case is
  # ignored on the way in, and chosen by the caller on the way out.
  #
  #   Utilities::Roman.to_i('xiv')            # => 14
  #   Utilities::Roman.to_i('XIV')            # => 14
  #   Utilities::Roman.from_i(14)             # => 'xiv'
  #   Utilities::Roman.from_i(14, upcase: true) # => 'XIV'
  #   Utilities::Roman.roman?('mix')          # => true
  #   Utilities::Roman.roman?('mixed')        # => false
  #
  # The domain is 1 to 4999. There is no zero and no negative in the notation,
  # and 5000 upwards would need a bar over the numeral that plain text has no
  # way to carry.
  module Roman

    MINIMUM = 1
    MAXIMUM = 4999

    DOMAIN = (MINIMUM..MAXIMUM).freeze

    PATTERN = /\A(?=[ivxlcdm])(m{0,4})(cm|cd|d?c{0,3})(xc|xl|l?x{0,3})(ix|iv|v?i{0,3})\z/i

    LITERALS = [
      ['m', 1000], ['cm', 900], ['d', 500], ['cd', 400],
      ['c', 100], ['xc', 90], ['l', 50], ['xl', 40],
      ['x', 10], ['ix', 9], ['v', 5], ['iv', 4], ['i', 1]
    ].freeze

    # @param value [Object]
    # @return [Boolean] true when value is a canonical roman numeral, in either
    #   case, ignoring surrounding whitespace
    def self.roman?(value)
      return false unless value.is_a?(String)

      candidate = value.strip
      !candidate.empty? && !PATTERN.match(candidate).nil?
    end

    # @param value [String]
    # @return [Integer]
    # @raise [ArgumentError] when value is not a canonical roman numeral
    def self.to_i(value)
      raise(ArgumentError, "not a roman numeral: #{value.inspect}") unless roman?(value)

      remaining = value.strip.downcase
      total = 0

      LITERALS.each do |literal, amount|
        while remaining.start_with?(literal)
          total += amount
          remaining = remaining[literal.length..]
        end
      end

      total
    end

    # @param value [String]
    # @return [Integer, nil] nil rather than an exception when value is not a
    #   canonical roman numeral
    def self.to_i_or_nil(value)
      roman?(value) ? to_i(value) : nil
    end

    # @param integer [Integer]
    # @param upcase [Boolean] lower case unless asked otherwise
    # @return [String]
    # @raise [ArgumentError] when integer falls outside 1..4999
    def self.from_i(integer, upcase: false)
      unless integer.is_a?(Integer) && DOMAIN.cover?(integer)
        raise(ArgumentError, "cannot express #{integer.inspect} as a roman numeral")
      end

      remaining = integer
      out = +''

      LITERALS.each do |literal, amount|
        while remaining >= amount
          out << literal
          remaining -= amount
        end
      end

      upcase ? out.upcase : out
    end
  end
end
