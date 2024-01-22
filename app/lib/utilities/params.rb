# Utilities for processing params. Probably grossly redundant with some gem and too permissive in general.
module Utilities
  module Params

    # @param value [String, Array, Symbol]
    # @return [Array of symbols]
    #   convert the value into an array of symbols
    def self.arrayify(value)
      case value.class.name
      when 'Array'
        value.map(&:to_sym)
      when 'Symbol'
        [value]
      when 'String'
        [value.to_sym]
      else
        raise "value to arrayify() is not an Array, Symbol, or String"
      end
    end
  end
end
