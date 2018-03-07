class TaxonNameRelationship::Iczn::Invalidating::Homonym::Primary::Forgotten < TaxonNameRelationship::Iczn::Invalidating::Homonym::Primary

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000106'.freeze

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        self.collect_to_s(TaxonNameRelationship::Iczn::Invalidating::Homonym::Primary) +
        self.collect_to_s(TaxonNameRelationship::Iczn::Invalidating::Homonym::Primary::Suppressed)
  end

  def object_status
    'protected primary homonym'
  end

  def subject_status
    'forgotten primary homonym'
  end

  def self.assignment_method
    # bus.set_as_iczn_forgotten_homonym_of(aus)
    :iczn_set_as_forgotten_homonym_of
  end

  def self.inverse_assignment_method
    # aus.iczn_forgotten_homonym = bus
    :iczn_forgotten_homonym
  end

  def self.nomenclatural_priority
    :reverse
  end


end