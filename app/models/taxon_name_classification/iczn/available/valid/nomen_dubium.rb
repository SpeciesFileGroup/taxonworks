class TaxonNameClassification::Iczn::Available::Valid::NomenDubium < TaxonNameClassification::Iczn::Available::Valid

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000225'

  def self.disjoint_taxon_name_classes
    self.parent.disjoint_taxon_name_classes + self.collect_to_s(
        TaxonNameClassification::Iczn::Available::Valid)
  end

  def self.gbif_status
    'dubimum'
  end

end
