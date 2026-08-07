class TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective::SynonymicHomonym < TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000287'.freeze

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        self.collect_to_s(
            TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective::UnjustifiedEmendation,
            TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective::UnnecessaryReplacementName,
            TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective::ReplacedHomonym)
  end

  def object_status
    'senior synonymic homonym'
  end

  def subject_status
    'synonymic homonym'
  end

  def self.assignment_method
    # bus.set_as_iczn_synonymic_homonym_of(aus)
    :iczn_set_as_synonymic_homonym_of
  end

  def self.inverse_assignment_method
    # aus.iczn_synonymic_homonym = bus
    :iczn_synonymic_homonym
  end

end
