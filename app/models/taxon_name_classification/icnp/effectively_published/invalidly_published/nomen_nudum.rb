class TaxonNameClassification::Icnp::EffectivelyPublished::InvalidlyPublished::NomenNudum < TaxonNameClassification::Icnp::EffectivelyPublished::InvalidlyPublished

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000090'.freeze

  def self.disjoint_taxon_name_classes
    self.parent.disjoint_taxon_name_classes + self.collect_to_s(
        TaxonNameClassification::Icnp::EffectivelyPublished::InvalidlyPublished)
  end

  def self.gbif_status
    'nudum'
  end

end
