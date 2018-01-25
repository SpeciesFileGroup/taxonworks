class TaxonNameRelationship::Iczn::Invalidating::Homonym::Primary::Suppressed < TaxonNameRelationship::Iczn::Invalidating::Homonym::Primary

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000108'.freeze

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        self.collect_to_s(TaxonNameRelationship::Iczn::Invalidating::Homonym::Primary) +
        self.collect_to_s(TaxonNameRelationship::Iczn::Invalidating::Homonym::Primary::Forgotten)
  end

  def object_status
    'conserved primary homonym'
  end

  def subject_status
    'suppressed primary homonym'
  end

  def self.assignment_method
    # bus.set_as_iczn_suppressed_homonym_of(aus)
    :iczn_set_as_suppressed_homonym_of
  end

  def self.inverse_assignment_method
    # aus.iczn_suppressed_homonym = bus
    :iczn_suppressed_homonym
  end

  def self.nomenclatural_priority
    :reverse
  end
end