class TaxonNameClassification::Iczn::Unavailable::Suppressed < TaxonNameClassification::Iczn::Unavailable

  def self.disjoint_taxon_name_classes
    self.parent.disjoint_taxon_name_classes +
        TaxonNameClassification::Iczn::Unavailable::Excluded.descendants.collect{|t| t.to_s} +
        [TaxonNameClassification::Iczn::Unavailable::Excluded.to_s] +
        TaxonNameClassification::Iczn::Unavailable::NomenNudum.descendants.collect{|t| t.to_s} +
        [TaxonNameClassification::Iczn::Unavailable::NomenNudum.to_s] +
        TaxonNameClassification::Iczn::Unavailable::NonBinomial.descendants.collect{|t| t.to_s} +
        [TaxonNameClassification::Iczn::Unavailable::NonBinomial.to_s]
  end

end
