class TaxonNameClassification::Iczn::Available::Valid < TaxonNameClassification::Iczn::Available

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000224'.freeze

  def self.disjoint_taxon_name_classes
    self.parent.disjoint_taxon_name_classes +
        self.collect_to_s(TaxonNameClassification::Iczn::Available::Invalid)
  end

  def self.gbif_status
    'valid'
  end

  def self.sv_not_specific_classes
    soft_validations.add(:type, 'This status should only be used when one or more conflicting invalidating relationships present in the database (for example, a taxon was used as a synonym in the past, but not now, and a synonym relationship is stored in the database for a historical record). Otherwise, this status should not be used. By default, any name which does not have invalidating relationship is a valid name')
  end


end
