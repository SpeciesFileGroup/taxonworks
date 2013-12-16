class TaxonNameClass::Icn < TaxonNameClass

  def self.disjoint_taxon_name_classes
    TaxonNameClass::Iczn.descendants.collect{|t| t.to_s}
  end

end
