class TaxonNameClassification::Iczn::Available < TaxonNameClassification::Iczn

  def self.disjoint_taxon_name_classes
    self.parent.disjoint_taxon_name_classes +
        self.collect_descendants_and_itself_to_s(TaxonNameClassification::Iczn::Unavailable)
  end

  def self.gbif_status
    'available'
  end

end
