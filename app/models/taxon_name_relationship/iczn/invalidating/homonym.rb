class TaxonNameRelationship::Iczn::Invalidating::Homonym < TaxonNameRelationship::Iczn::Invalidating

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000289'.freeze

  soft_validate(:sv_validate_homonym_relationships, set: :validate_homonym_relationships)

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        self.collect_descendants_to_s(TaxonNameRelationship::Iczn::Invalidating::Usage) +
        self.collect_to_s(TaxonNameRelationship::Iczn::Invalidating,
            TaxonNameRelationship::Iczn::Invalidating::Synonym::Suppression::Total)

  end

#  def self.disjoint_object_classes
#    self.parent.disjoint_object_classes
#  end

  def subject_properties
    [ TaxonNameClassification::Iczn::Available::Invalid::Homonym ]
  end

  def object_status
    'senior homonym'
  end

  def subject_status
    'homonym'
  end

  def subject_status_connector_to_object
    ' of'
  end

  def object_status_connector_to_subject
    ' of'
  end

  def self.assignment_method
    # bus.set_as_iczn_homonym_of(aus)
    :iczn_set_as_homonym_of
  end

  # as.
  def self.inverse_assignment_method
    # aus.iczn_homonym = bus
    :iczn_homonym
  end

  def sv_add_synonym_for_homonym
    # if self.type_name =~ /TaxonNameRelationship::Iczn::Invalidating::Homonym/
    if self.subject_taxon_name.iczn_set_as_synonym_of.nil?
      unless self.subject_taxon_name.iczn_replacement_names.empty?
        self.subject_taxon_name.iczn_set_as_synonym_of = self.object_taxon_name
        begin
          TaxonNameRelationship.transaction do
            self.save
            return true
          end
        rescue
        end
      end
    end
    # end
    false
  end

  def sv_validate_homonym_relationships
    #  if self.type_name =~ /TaxonNameRelationship::Iczn::Invalidating::Homonym/
    if !self.object_taxon_name.iczn_set_as_total_suppression_of.nil?
      soft_validations.add(:type, 'Taxon should not be treated as homonym, since the related taxon is totally suppressed')
    elsif self.subject_taxon_name.iczn_set_as_synonym_of.nil?
      if self.subject_taxon_name.iczn_replacement_names.empty?
        soft_validations.add(:type, 'Please select a nomen novum and/or valid name')
      else
        soft_validations.add(:type, 'Please select a valid name using synonym relationships',
                             fix: :sv_add_synonym_for_homonym, success_message: 'Synonym relationship was added')
      end
    end
    #  end
  end


end
