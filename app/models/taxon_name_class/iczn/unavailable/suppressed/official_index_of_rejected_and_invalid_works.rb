class TaxonNameClass::Iczn::Unavailable::Suppressed::OfficialIndexOfRejectedAndInvalidWorks < TaxonNameClass::Iczn::Unavailable::Suppressed

  def self.disjoint_taxon_name_classes
    self.parent.disjoint_taxon_name_classes +
        [TaxonNameClass::Iczn::Unavailable::Suppressed.to_s] +
        [TaxonNameClass::Iczn::Unavailable::Suppressed::OfficialIndexOfUnavailableNames.to_s] +
        [TaxonNameClass::Iczn::Unavailable::Suppressed::NotInOfficialListOfAvailableNames.to_s]
  end

end
