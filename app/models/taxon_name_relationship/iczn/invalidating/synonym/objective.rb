class TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective < TaxonNameRelationship::Iczn::Invalidating::Synonym

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000277'.freeze

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        self.collect_descendants_and_itself_to_s(TaxonNameRelationship::Iczn::Invalidating::Synonym::Suppression) +
        self.collect_to_s(TaxonNameRelationship::Iczn::Invalidating::Synonym,
            TaxonNameRelationship::Iczn::Invalidating::Synonym::ForgottenName)
  end

  def object_status
    'senior objective synonym'
  end

  def subject_status
    'objective synonym'
  end

  def self.assignment_method
    # bus.set_as_iczn_objective_synonym_of(aus)
    :iczn_set_as_objective_synonym_of
  end

  # as.
  def self.inverse_assignment_method
    # aus.iczn_objective_synonym = bus
    :iczn_objective_synonym
  end

  def sv_objective_synonym_relationship
    s = self.subject_taxon_name
    o = self.object_taxon_name
    if (s.type_taxon_name != o.type_taxon_name ) || !s.has_same_primary_type(o)
      soft_validations.add(:type, "Objective synonyms #{s.cached_html} and #{o.cached_html} should have the same type")
    end
  end

  def sv_fix_objective_synonym_relationship
    fixed = false
    s = self.subject_taxon_name
    o = self.object_taxon_name
    if s.get_primary_type.empty?
      t2 = s
      t1 = o
    elsif o.get_primary_type.empty?
      t2 = o
      t1 = s
    else
      return false
    end

      types2 = t1.get_primary_type
      if !types2.empty?
        new_type_material = []
        types2.each do |t|
          new_type_material.push({type_type: t.type_type, protonym_id: t2.id, collection_object_id: t.collection_object_id, source: t.source})
        end
        t2.type_materials.build(new_type_material)
        fixed = true
      end

    if fixed
      begin
        Protonym.transaction do
          t2.save
        end
        return true
      rescue
        return false
      end
    end
  end

  def sv_not_specific_relationship
    true
  end
end
