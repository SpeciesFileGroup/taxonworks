class TaxonNameRelationship::Iczn::Invalidating::Homonym::Secondary::Secondary1961 <  TaxonNameRelationship::Iczn::Invalidating::Homonym::Secondary

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000292'

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        [TaxonNameRelationship::Iczn::Invalidating::Homonym::Secondary.to_s]
  end

  def subject_relationship_name
    'secondary senior homonym replacement before 1961'
  end

  def object_relationship_name
    'secondary homonym replaced before 1961'
  end

  def self.assignment_method
    # bus.set_as_iczn_secondary_homonym_before_1961_of(aus)
    :iczn_set_as_secondary_homonym_before_1961_of
  end

  def self.inverse_assignment_method
    # aus.iczn_secondary_homonym_before_1961 = bus
    :iczn_secondary_homonym_before_1961
  end

end
