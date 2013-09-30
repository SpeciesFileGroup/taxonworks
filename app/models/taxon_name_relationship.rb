class TaxonNameRelationship < ActiveRecord::Base

  validates_presence_of :type, :subject_taxon_name_id, :object_taxon_name_id
 
  belongs_to :object, class_name: 'TaxonName', foreign_key: :object_taxon_name_id
  belongs_to :subject, class_name: 'TaxonName', foreign_key: :subject_taxon_name_id

  before_validation :validate_type


  def aliases
    []
  end

  def object_properties
    [] 
  end 

  def subject_properties

  end

  
  def self.valid?(type)
    ::TAXON_NAME_RELATIONSHIP_NAMES.include(type.to_s)
  end

  protected

  def validate_type
    errors.add(:type, "invalid taxon name relationship") if !::TAXON_NAME_RELATIONSHIPS.include?(type)
  end

end
