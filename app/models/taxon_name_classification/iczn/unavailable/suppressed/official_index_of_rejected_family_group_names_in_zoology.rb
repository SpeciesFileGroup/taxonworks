class TaxonNameClassification::Iczn::Unavailable::Suppressed::OfficialIndexOfRejectedFamilyGroupNamesInZoology < TaxonNameClassification::Iczn::Unavailable::Suppressed

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000222'.freeze

  def self.applicable_ranks
    FAMILY_RANK_NAMES_ICZN
  end

  def self.disjoint_taxon_name_classes
    self.parent.disjoint_taxon_name_classes + self.collect_to_s(
        TaxonNameClassification::Iczn::Unavailable::Suppressed,
        TaxonNameClassification::Iczn::Unavailable::Suppressed::OfficialIndexOfRejectedAndInvalidWorksInZoology,
        TaxonNameClassification::Iczn::Unavailable::Suppressed::NotInOfficialListOfAvailableNamesInZoology,
        TaxonNameClassification::Iczn::Unavailable::Suppressed::OfficialIndexOfRejectedGenericNamesInZoology,
        TaxonNameClassification::Iczn::Unavailable::Suppressed::OfficialIndexOfRejectedSpecificNamesInZoology)
  end

  def classification_label
    'Official Index of Rejected Family Group Names in Zoological Nomenclature'
  end
end
