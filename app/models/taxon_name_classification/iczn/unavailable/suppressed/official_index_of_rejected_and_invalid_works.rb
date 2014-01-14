class TaxonNameClassification::Iczn::Unavailable::Suppressed::OfficialIndexOfRejectedAndInvalidWorks < TaxonNameClassification::Iczn::Unavailable::Suppressed

  def self.disjoint_taxon_name_classes
    self.parent.disjoint_taxon_name_classes +
        [TaxonNameClassification::Iczn::Unavailable::Suppressed.to_s] +
        [TaxonNameClassification::Iczn::Unavailable::Suppressed::OfficialIndexOfUnavailableNames.to_s] +
        [TaxonNameClassification::Iczn::Unavailable::Suppressed::NotInOfficialListOfAvailableNames.to_s]
  end

end
