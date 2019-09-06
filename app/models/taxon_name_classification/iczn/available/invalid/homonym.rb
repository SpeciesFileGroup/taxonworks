class TaxonNameClassification::Iczn::Available::Invalid::Homonym < TaxonNameClassification::Iczn::Available::Invalid

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000043'.freeze

  LABEL = 'homonym'.freeze

  def self.disjoint_taxon_name_classes
    self.parent.disjoint_taxon_name_classes +
        self.collect_to_s(TaxonNameClassification::Iczn::Available::Invalid)
  end

  def sv_not_specific_classes
    soft_validations.add(:type, 'Although this status can be used, it is better to replace it with with appropriate relationship (for example Primary Homonym)')
  end
end
