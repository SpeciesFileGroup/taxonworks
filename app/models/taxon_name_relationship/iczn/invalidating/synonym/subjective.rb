class TaxonNameRelationship::Iczn::Invalidating::Synonym::Subjective < TaxonNameRelationship::Iczn::Invalidating::Synonym

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000285'.freeze

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        self.collect_descendants_and_itself_to_s(TaxonNameRelationship::Iczn::Invalidating::Synonym::Suppression) +
        self.collect_to_s(TaxonNameRelationship::Iczn::Invalidating::Synonym)
  end

  def object_status
    'senior subjective synonym'
  end

  def subject_status
    'subjective synonym'
  end

  def self.assignment_method
    # bus.set_as_iczn_subjective_synonym_of(aus)
    :iczn_set_as_subjective_synonym_of
  end

  # as.
  def self.inverse_assignment_method
    # aus.iczn_subjective_synonym = bus
    :iczn_subjective_synonym
  end

  def sv_specific_relationship
    s = subject_taxon_name
    o = object_taxon_name
    if (s.type_taxon_name == o.type_taxon_name && !s.type_taxon_name.nil? ) || (!s.get_primary_type.empty? && s.has_same_primary_type(o) )
      soft_validations.add(:type, "Subjective synonyms #{s.cached_html} and #{o.cached_html} should not have the same type")
    end
  end

  def sv_validate_seniority
    if self.subject_taxon_name.cached_nomenclature_date == self.object_taxon_name.cached_nomenclature_date && subject_invalid_statuses.empty?
      r1 = self.subject_taxon_name.original_combination_relationships.reload.sort{|a,b| ORIGINAL_COMBINATION_RANKS.index(a.type) <=> ORIGINAL_COMBINATION_RANKS.index(b.type) }
      r2 = self.object_taxon_name.original_combination_relationships.reload.sort{|a,b| ORIGINAL_COMBINATION_RANKS.index(a.type) <=> ORIGINAL_COMBINATION_RANKS.index(b.type) }
      if !r1.empty? && !r2.empty? && ORIGINAL_COMBINATION_RANKS.index(r1.last.type) < ORIGINAL_COMBINATION_RANKS.index(r2.last.type) && TaxonNameRelationship.where_subject_is_taxon_name(self.subject_taxon_name).with_two_type_bases('TaxonNameRelationship::Iczn::Invalidating::Homonym', 'TaxonNameRelationship::Iczn::Validating').not_self(self).empty?
        soft_validations.add(:base, "#{self.subject_taxon_name.cached_original_combination_html} has priority; it was described simultaneously, but at higher rank than #{self.object_taxon_name.cached_original_combination_html}")
      end
    end
  end

  def sv_not_specific_relationship
    true
  end
end
