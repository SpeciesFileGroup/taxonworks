module Utilities::Numbers

  # @param [Integer] number
  # @return [Array] of numbers 0 - 32
  def self.get_bits(number)
    # created by Jim Tucker, 20161012
    # parameter is decimal number representing a bit map
    # returns an array of bits set (power of 2) starting at 0, e.g., [0, 3, 22]
    # use to decode StatusFlags in SF.tblTaxa
    ret_val = []
    counter = 0

    until number == 0
      ret_val << counter unless (number & 1) == 0 # << = push
      counter += 1
      number >>= 1 # >>= = right shift
    end

    ret_val
  end

end
