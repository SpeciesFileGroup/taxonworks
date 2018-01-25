class TaxonNameClassification::Iczn::Available::OfficialListOfGenericNamesInZoology < TaxonNameClassification::Iczn::Available

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000228'.freeze

  def self.applicable_ranks
    GENUS_RANK_NAMES_ICZN
  end

  def self.disjoint_taxon_name_classes
    self.parent.disjoint_taxon_name_classes + self.collect_to_s(
        TaxonNameClassification::Iczn::Available::OfficialListOfSpecificNamesInZoology,
        TaxonNameClassification::Iczn::Available::OfficialListOfFamilyGroupNamesInZoology
    )
  end

  def classification_label
    'Official List of Generic Names in Zoological Nomenclature'
  end
end
