module Latin

  ENDINGS = {
    'er' => %w{ra era rum},
    'or' => %w{rix}, 
    'ae' => %w{ei a e i},
    'anum' => %w{ensis},
    'major' => %w{majus},
    's' => %w{es is us},
    'm' => %w{um}
  }

  def self.same_root_name?(name1, name2)
    return false if (name1.length - name2.length).abs > 1
  end

  # An Array of all endings sorted by length, longest first
  def self.all_endings
    (ENDINGS.keys + ENDINGS.values).flatten.sort{|a,b| b.length <=> a.length}
  end

  def self.root(name)
    key = nil
    self.all_endings.each do |e|
      if name =~ /(.*)#{e}\Z/   # match Some String + an ending (e) that happens at the end of a string
        return $1
      end
    end
    false
  end


end


