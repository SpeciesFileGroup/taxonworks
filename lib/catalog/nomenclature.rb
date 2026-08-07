class Catalog::Nomenclature < ::Catalog

  # @return [Array of TaxonName]
  #   all names observed in this catalog. For example the index.
  def names
    n = []
    entries.each do |e|
      n += e.all_names
    end
    n.uniq
  end

end
