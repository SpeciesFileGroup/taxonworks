module Utilities::Hashes

  # Pass two hashes, a and b, print out those
  # situations in which a.merge(b) would change
  # a value assigned in a to something different (assigned in b)
  # @param [Hash] a
  # @param [Hash] b
  def self.puts_collisions(a, b)
    a.each do |i,j|
      if b[i] && !j.blank? && b[i] != j
        puts "#{i}: [#{j}] != [#{b[i]}]"
      end
    end
  end

  # Delete all matching keys in array from the hsh
  # @param [Hash] hsh
  # @param [Array] array
  # @return [Hash]
  def self.delete_keys(hsh, array)
    hsh.delete_if{|k,v| array.include?(k)}
  end

  # @param [Hash] hash
  # @return [Hash]
  def self.symbolize_keys(hash)
    hash.inject({}) do |h, (k, v)|
      h[k.is_a?(String) ? k.to_sym : k] = (v.is_a?(Hash) ? symbolize_keys(v) : v)
      h
    end
  end

  # Sets value at key in hsh iff value is not nil
  # @param [Hash] hsh
  # @param [Object] key
  # @param [Object] value
  def self.set_unless_nil(hsh, key, value)
    hsh[key] = value unless value.nil?
  end  
  
  # Delete all nil and empty hashes values
  # @param [Hash] hsh
  # @return [Hash]
  def self.delete_nil_and_empty_hash_values(hsh)
    hsh.each do |key, value|
      hsh.delete(key) if hsh[key].nil? || hsh[key] == {}
    end
    hsh
  end
end
