class TaxonNameClassification::Iczn::Available::OfficialListOfSpecificNamesInZoology < TaxonNameClassification::Iczn::Available

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000059'

  def self.applicable_ranks
    SPECIES_RANK_NAMES_ICZN
  end

  def self.disjoint_taxon_name_classes
    self.parent.disjoint_taxon_name_classes + self.collect_to_s(
        TaxonNameClassification::Iczn::Available::OfficialListOfGenericNamesInZoology,
        TaxonNameClassification::Iczn::Available::OfficialListOfFamilyGroupNamesInZoology
    )
  end


end
