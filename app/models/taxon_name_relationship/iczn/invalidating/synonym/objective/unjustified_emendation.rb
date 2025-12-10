class TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective::UnjustifiedEmendation < TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000278'.freeze

  soft_validate(
    :sv_different_original_genera,
    set: :specific_relationship,
    fix: :sv_fix_different_original_genera,
    name: 'validate relationship',
    description: 'Validate integrity of the relationship, for example, the year applicability range' )


  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        self.collect_to_s(TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective,
            TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective::SynonymicHomonym,
            TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective::UnnecessaryReplacementName,
            TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective::ReplacedHomonym)
  end

  def object_status
    'correct original spelling'
  end

  def subject_status
    'unjustified emendation'
  end

  def subject_status_connector_to_object
    ' for'
  end

  def self.assignment_method
    # bus.set_as_iczn_unjustified_emendation_of(aus)
    :iczn_set_as_unjustified_emendation_of
  end

  def self.inverse_assignment_method
    # aus.iczn_unjustified_emendation = bus
    :iczn_unjustified_emendation
  end

  protected

  def sv_specific_relationship
    s = self.subject_taxon_name
    o = self.object_taxon_name
    if s.name == o.name
      soft_validations.add(:base, "Unjustified emendation and correctly spelled names are identical: '#{s.cached_html}'")
    end
  end

  def sv_different_original_genera
    s = self.subject_taxon_name
    o = self.object_taxon_name
    if o.is_species_rank? && o.original_genus && s.original_genus != o.original_genus
      soft_validations.add(:type, "Unjustified emendation and correctly spelled names should have the same original genus: '#{o.original_genus.cached_html}'", success_message: 'Original genus was updated', failure_message:  'Failed to update original genus')
    end
  end
  def sv_fix_different_original_genera
    s = self.subject_taxon_name
    o = self.object_taxon_name
    if o.is_species_rank? && s.original_genus.nil? && o.original_genus
      begin
        Protonym.transaction do
          s.original_genus = o.original_genus
          s.original_species = s if s.original_species.nil?
          s.save
        end
        return true
      rescue
        return false
      end
    else
      return false
    end
  end
end
