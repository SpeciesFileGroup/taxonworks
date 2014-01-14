class TaxonNameClassification::Icn < TaxonNameClassification

  def self.disjoint_taxon_name_classes
    TaxonNameClassification::Iczn.descendants.collect{|t| t.to_s}
  end

end
