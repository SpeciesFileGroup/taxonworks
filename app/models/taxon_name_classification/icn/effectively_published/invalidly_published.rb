class TaxonNameClassification::Icn::EffectivelyPublished::InvalidlyPublished < TaxonNameClassification::Icn::EffectivelyPublished

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000008'.freeze

  def self.disjoint_taxon_name_classes
    self.parent.disjoint_taxon_name_classes +
        [TaxonNameClassification::Icn::EffectivelyPublished.to_s] +
        self.collect_descendants_and_itself_to_s(TaxonNameClassification::Icn::EffectivelyPublished::ValidlyPublished)
  end

  def self.gbif_status
    'invalidum'
  end

  def self.sv_not_specific_classes
    soft_validations.add(:type, 'Please specify the reasons for the name being Invalidly Published')
  end
end