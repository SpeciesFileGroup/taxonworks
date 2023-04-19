class TaxonNameRelationship::Icn::Unaccepting::OriginallyInvalid < TaxonNameRelationship::Icn::Unaccepting

NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000700'.freeze

  validates_uniqueness_of :object_taxon_name_id, scope: :type

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
      self.collect_to_s(TaxonNameRelationship::Icn::Unaccepting::Usage,
                        TaxonNameRelationship::Icn::Unaccepting::Synonym,
                        TaxonNameRelationship::Icn::Unaccepting::Homonym,
                        TaxonNameRelationship::Icn::Unaccepting::Misapplication) +
      self.collect_descendants_to_s(TaxonNameRelationship::Icn::Unaccepting::Usage,
                                    TaxonNameRelationship::Icn::Unaccepting::Synonym,
                                    TaxonNameRelationship::Icn::Unaccepting::Homonym,
                                    )
  end

  def self.disjoint_subject_classes
    self.parent.disjoint_subject_classes +
      self.collect_to_s(TaxonNameClassification::Icn::NotEffectivelyPublished)
  end

  def subject_properties
    [ TaxonNameClassification::Icn::NotEffectivelyPublished ]
  end

  def object_status
    'validly published name'
  end

  def subject_status
    'original unaccepted name'
  end

  def self.gbif_status_of_subject
    'ambigua'
  end

  def self.assignment_method
    :icn_set_as_original_unaccepted_of
  end

  def self.inverse_assignment_method
    :icn_validly_published_for
  end

  def self.nomenclatural_priority
    :direct
  end

  def self.assignable
    true
  end

  def object_status
    'invalidly published'
  end

  def subject_status
    'validly published'
  end

  def subject_status_connector_to_object
    ' as'
  end

  def object_status_connector_to_subject
    ' for'
  end
end
