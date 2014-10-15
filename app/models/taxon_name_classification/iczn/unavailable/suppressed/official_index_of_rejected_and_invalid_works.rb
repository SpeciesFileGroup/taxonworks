class TaxonNameClassification::Iczn::Unavailable::Suppressed::OfficialIndexOfRejectedAndInvalidWorks < TaxonNameClassification::Iczn::Unavailable::Suppressed

  def self.disjoint_taxon_name_classes
    self.parent.disjoint_taxon_name_classes + self.collect_to_s(
        TaxonNameClassification::Iczn::Unavailable::Suppressed,
        TaxonNameClassification::Iczn::Unavailable::Suppressed::OfficialIndexOfUnavailableNames,
        TaxonNameClassification::Iczn::Unavailable::Suppressed::NotInOfficialListOfAvailableNames,
        TaxonNameClassification::Iczn::Unavailable::Suppressed::Work)
  end

end
