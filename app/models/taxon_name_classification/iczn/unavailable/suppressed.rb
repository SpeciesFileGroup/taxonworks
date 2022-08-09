class TaxonNameClassification::Iczn::Unavailable::Suppressed < TaxonNameClassification::Iczn::Unavailable

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000219'.freeze

  def self.disjoint_taxon_name_classes
    self.parent.disjoint_taxon_name_classes +
        self.collect_descendants_and_itself_to_s(TaxonNameClassification::Iczn::Unavailable::Excluded,
            TaxonNameClassification::Iczn::Unavailable::NomenNudum) +
        self.collect_to_s(TaxonNameClassification::Iczn::Unavailable)
  end

  def self.gbif_status
    'rejiciendum'
  end

  def sv_not_specific_classes
    soft_validations.add(:type, 'Please specify the reasons for the name being Suppressed')
  end
end
