class TaxonNameClassification::Iczn::Available < TaxonNameClassification::Iczn

  def self.applicable_ranks
    ICZN.collect{|t| t.to_s}
  end

  def self.disjoint_taxon_name_classes
    self.parent.disjoint_taxon_name_classes +
        TaxonNameClassification::Iczn::Unavailable.descendants.collect{|t| t.to_s} +
        [TaxonNameClassification::Iczn::Unavailable.to_s]
  end

end
