class TaxonNameRelationship < ActiveRecord::Base

  validates_presence_of :type, :subject_taxon_name_id, :object_taxon_name_id
  validates_uniqueness_of :subject_taxon_name_id,  scope: [:type, :object_taxon_name_id]

  belongs_to :subject, class_name: 'TaxonName', foreign_key: :subject_taxon_name_id
  belongs_to :object, class_name: 'TaxonName', foreign_key: :object_taxon_name_id

  before_validation :validate_type, :validate_subject_and_object_share_code

  def aliases
    []
  end

  def self.object_properties
    [] 
  end 

  def self.subject_properties
    []
  end
  
  protected

  # TODO: Flesh this out vs. TaxonName#rank_class.  Ensure that FactoryGirl type can be set in postgres branch.
  def validate_type
    errors.add(:type, "'#{type}' is not a valid taxon name relationship") if !::TAXON_NAME_RELATIONSHIP_NAMES.include?(type.to_s)
  end

  def validate_subject_and_object_share_code
    if object.class == Protonym and subject.class == Protonym
#      if ![object.class, subject.class].include?(Combination)
      errors.add(:object_id, "The related taxon if from different nomenclatural code") if subject.rank_class.nomenclatural_code != object.rank_class.nomenclatural_code
    end
  end



end
