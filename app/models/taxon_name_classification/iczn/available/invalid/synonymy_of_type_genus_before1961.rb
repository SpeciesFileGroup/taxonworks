class TaxonNameClassification::Iczn::Available::Invalid::SynonymyOfTypeGenusBefore1961 < TaxonNameClassification::Iczn::Available::Invalid

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0001061'.freeze

  def classification_label
    'invalid due to synonymy of type genus before 1961'
  end

  def self.applicable_ranks
    FAMILY_RANK_NAMES_ICZN
  end

  def self.disjoint_taxon_name_classes
    self.parent.disjoint_taxon_name_classes +
        self.collect_to_s(TaxonNameClassification::Iczn::Available::Invalid,
                          TaxonNameClassification::Iczn::Available::Invalid::Homonym,
                          TaxonNameClassification::Iczn::Available::Invalid::HomonymyOfTypeGenus,
                          TaxonNameClassification::Iczn::Available::Invalid::SuppressionOfTypeGenus)
  end

  def sv_not_specific_classes
    true
  end
end