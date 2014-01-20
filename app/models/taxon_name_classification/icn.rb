class TaxonNameClassification::Icn < TaxonNameClassification

  def self.disjoint_taxon_name_classes
    self.collect_descentants_to_s(TaxonNameClassification::Iczn)
  end

end
