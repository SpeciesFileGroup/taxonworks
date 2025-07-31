# Methods that receive or generate a String. All methods are dependant on some Rails provided method.
module Utilities::Rails::Strings

  # @param [String] string
  # @return [String, nil]
  #  strips pre/post fixed space and condenses internal spaces, but returns nil (not empty string) if nothing is left
  def self.nil_squish_strip(string)
    a = string.dup
    if !a.nil?
      a.squish!
      a = nil if a == ''
    end
    a
  end
end
