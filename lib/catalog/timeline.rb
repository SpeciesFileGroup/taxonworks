class Catalog::Timeline < Catalog

  def build
    catalog_targets.each do |t|
      @entries.push Catalog::Otu::Entry.new(t)
      @entries.push Catalog::Nomenclature::Entry.new(t.taxon_name) if t.taxon_name
    end
  end

end

