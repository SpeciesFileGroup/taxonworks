class Catalog::Nomenclature < Catalog


  # @return [Array of TaxonName]
  #   all names observed in this catalog. For example the index.
  def names
    n = []
    entries.each do |e|
      n += e.all_names
    end   
    n.uniq
  end

  # @return [Array of TaxonName]
  #   all topics observed in this catalog. For example the index.
  def topics
    t = []
    entries.each do |e|
      t += e.topics
    end   
    t.uniq
  end

end
