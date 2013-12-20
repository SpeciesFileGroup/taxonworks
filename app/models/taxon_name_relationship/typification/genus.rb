class TaxonNameRelationship::Typification::Genus < TaxonNameRelationship::Typification

   # left side
  def self.valid_subject_ranks
    NomenclaturalRank::Iczn::SpeciesGroup.descendants.collect{|t| t.to_s} + NomenclaturalRank::Icn::SpeciesAndInfraspeciesGroup.descendants.collect{|t| t.to_s}
  end

   # right_side
  def self.valid_object_ranks
    NomenclaturalRank::Iczn::GenusGroup.descendants.collect{|t| t.to_s} + NomenclaturalRank::Icn::GenusGroup.descendants.collect{|t| t.to_s}
  end

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
    [TaxonNameRelationship::Typification::Family.to_s]
  end

  def self.subject_relationship_name
    'type species'
  end

  def self.assignment_method
    # used like:
    #
    #   right_side instance   =  left_side instance
    #   genus.type_species = species
    #   genus.type_species_relationship # => returns a TaxonNameRelationship
    :type_species
  end

  def self.inverse_assignment_method
    # used like
    #    left_side_instance        right_side_instance
    #    species.type_of_genus(genus)
    :type_of_genus
  end

  def self.assignable
    true
  end

end
