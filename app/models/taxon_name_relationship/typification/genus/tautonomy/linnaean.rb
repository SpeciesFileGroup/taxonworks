# frozen_string_literal: true
# Defines a Tautonomy b/w subject and object.
# TODO: missing URI
class TaxonNameRelationship::Typification::Genus::Tautonomy::Linnaean < TaxonNameRelationship::Typification::Genus::Tautonomy

  def self.disjoint_taxon_name_relationships
    parent.disjoint_taxon_name_relationships +
      collect_to_s(
        TaxonNameRelationship::Typification::Genus::Tautonomy,
        TaxonNameRelationship::Typification::Genus::Tautonomy::Absolute
      )
  end

  def object_status
    'type of genus by Linnaean tautonomy'
  end

  def subject_status
    'type species by Linnaean tautonomy'
  end

  def self.assignment_method
    :type_of_genus_by_Linnaean_tautonomy
  end

  def self.inverse_assignment_method
    :type_species_by_Linnaean_tautonomy
  end

  def sv_not_specific_relationship
    true
  end
end
