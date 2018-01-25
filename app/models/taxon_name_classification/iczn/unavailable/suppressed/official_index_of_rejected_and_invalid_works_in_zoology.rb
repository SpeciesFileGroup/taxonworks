class TaxonNameClassification::Iczn::Unavailable::Suppressed::OfficialIndexOfRejectedAndInvalidWorksInZoology < TaxonNameClassification::Iczn::Unavailable::Suppressed

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000024'.freeze

  def self.disjoint_taxon_name_classes
    self.parent.disjoint_taxon_name_classes + self.collect_to_s(
        TaxonNameClassification::Iczn::Unavailable::Suppressed,
        TaxonNameClassification::Iczn::Unavailable::Suppressed::OfficialIndexOfRejectedFamilyGroupNamesInZoology,
        TaxonNameClassification::Iczn::Unavailable::Suppressed::OfficialIndexOfRejectedGenericNamesInZoology,
        TaxonNameClassification::Iczn::Unavailable::Suppressed::OfficialIndexOfRejectedSpecificNamesInZoology,
        TaxonNameClassification::Iczn::Unavailable::Suppressed::NotInOfficialListOfAvailableNamesInZoology)
  end

  def classification_label
    'Official Index of Rejected and Invalid Works in Zoological Nomenclature'
  end
end
