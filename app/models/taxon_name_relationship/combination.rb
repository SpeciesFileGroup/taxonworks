# The class relationships used to create Combinations.
class TaxonNameRelationship::Combination < TaxonNameRelationship
  
  validates_uniqueness_of :object_taxon_name_id, scope: :type
  validate :subject_is_protonym

  # This is over-writing the assignment in taxon_name.rb, which restricts destroy.
  # In this case we want to destroy all the relationships.
  has_many :related_taxon_name_relationships, class_name: 'TaxonNameRelationship', 
    foreign_key: :object_taxon_name_id, 
    inverse_of: :object_taxon_name

  def subject_is_protonym
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
    ' as ' +  type_name.demodulize.underscore.humanize.downcase + ' in combination'
  end

  # @return String
  def subject_status_connector_to_object
    ''
  end

  # @return String
  def object_status_connector_to_subject
    ' with'
  end

end
