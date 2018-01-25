class TaxonNameClassification::Iczn::Available::OfficialListOfFamilyGroupNamesInZoology < TaxonNameClassification::Iczn::Available

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000229'.freeze

  def self.applicable_ranks
    FAMILY_RANK_NAMES_ICZN
  end

  def self.disjoint_taxon_name_classes
    self.parent.disjoint_taxon_name_classes + self.collect_to_s(
        TaxonNameClassification::Iczn::Available::OfficialListOfSpecificNamesInZoology,
        TaxonNameClassification::Iczn::Available::OfficialListOfGenericNamesInZoology
    )
  end

  def classification_label
    'Official List of Family Group Names in Zoological Nomenclature'
  end
end
