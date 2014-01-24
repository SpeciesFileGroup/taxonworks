class TaxonNameClassification::Iczn::Unavailable::Suppressed < TaxonNameClassification::Iczn::Unavailable

  def self.disjoint_taxon_name_classes
    self.parent.disjoint_taxon_name_classes +
        self.collect_descendants_and_itself_to_s(TaxonNameClassification::Iczn::Unavailable::Excluded,
            TaxonNameClassification::Iczn::Unavailable::NomenNudum,
            TaxonNameClassification::Iczn::Unavailable::NonBinomial) +
        self.collect_to_s(TaxonNameClassification::Iczn::Unavailable)
  end

end
