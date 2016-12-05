class TaxonNameRelationship::Combination < TaxonNameRelationship

  # Abstract class.
  validates_uniqueness_of :object_taxon_name_id, scope: :type

  def validate_subject_is_protonym
    errors.add(:subject_taxon_name, 'Must be a protonym') if subject_taxon_name.type == 'Combination'
  end

  def self.order_index
    RANKS.index(::ICN_LOOKUP[self.name.demodulize.underscore.humanize.downcase])
  end

  def self.disjoint_classes
    self.collect_descendants_to_s(TaxonNameClassification)
  end

  def self.disjoint_subject_classes
    self.disjoint_classes
  end

  def self.disjoint_object_classes
    self.disjoint_classes
  end

  def self.nomenclatural_priority
    :reverse
  end

  # @return String
  #    the status inferred by the relationship to the object name 
  def object_status
    self.type_name.demodulize.underscore.humanize.downcase + ' in combination'
  end

  # @return String
  #    the status inferred by the relationship to the subject name 
  def subject_status
    ' as ' +  self.type_name.demodulize.underscore.humanize.downcase + ' in combination'
  end

  def subject_status_connector_to_object
    ''
  end


  def object_status_connector_to_subject
    ' with'
  end




end
