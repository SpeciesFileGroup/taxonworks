class TaxonNameClassification::Iczn::Available::Invalid < TaxonNameClassification::Iczn::Available

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000226'.freeze

  def self.disjoint_taxon_name_classes
    self.parent.disjoint_taxon_name_classes +
        self.collect_to_s(TaxonNameClassification::Iczn::Available::Valid)
  end

  def self.gbif_status
    'invalidum'
  end

  def label
    'invalid'
  end

  def sv_not_specific_classes
    soft_validations.add(:type, 'Although this status can be used, it is better to replace it with appropriate relationship (for example Synonym relationship)')
  end
end
