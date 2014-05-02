module Utilities::Hashes

  # Pass two hashes, a and b, print out those
  # situations in which a.merge(b) would change
  # a value assigned in a to something different (assigned in b) 
  def self.puts_collisions(a, b)
    a.each do |i,j|
      if b[i] && !j.blank? && b[i] != j 
        puts "#{i}: [#{j}] != [#{b[i]}]"
      end
    end
  end

  # Delete all matching keys in array from the hsh
  def self.delete_keys(hsh, array)
    hsh.delete_if{|k,v| array.include?(k)}
  end

end
