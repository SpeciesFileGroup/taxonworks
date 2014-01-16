class TaxonNameRelationship < ActiveRecord::Base

  include Housekeeping
  include Shared::Citable
  include SoftValidation

  belongs_to :subject_taxon_name, class_name: 'TaxonName', foreign_key: :subject_taxon_name_id # left side
  belongs_to :object_taxon_name, class_name: 'TaxonName', foreign_key: :object_taxon_name_id   # right side
  belongs_to :source

  soft_validate(:sv_validate_disjoint_relationships, set: :disjoint)
  soft_validate(:sv_validate_disjoint_object, set: :disjoint_object)
  soft_validate(:sv_validate_disjoint_subject, set: :disjoint_subject)

  validates_presence_of :type, message: 'Relationship type should be specified'
  validates_presence_of :subject_taxon_name_id, message: 'Taxon is not selected'
  validates_presence_of :object_taxon_name_id, message: 'Taxon is not selected'
  validates_uniqueness_of :object_taxon_name_id, scope: :type, if: :is_combination?
  validates_uniqueness_of :object_taxon_name_id, scope: [:type, :subject_taxon_name_id], unless: :is_combination?
  before_validation :validate_type,
    :validate_subject_and_object_share_code,
    :validate_valid_subject_and_object,
    :validate_uniqueness_of_synonym_subject,
    :validate_uniqueness_of_typification_object

  # TODO: refactor once housekeeping stabilizes
  before_validation :assign_houskeeping_if_possible, on: :create

  scope :where_subject_is_taxon_name, -> (taxon_name) {where(subject_taxon_name_id: taxon_name)}
  scope :where_object_is_taxon_name, -> (taxon_name) {where(object_taxon_name_id: taxon_name)}
  scope :with_type, -> (type_string) {where('type LIKE ?', "#{type_string}" ) }
  scope :with_type_base, -> (base_string) {where('type LIKE ?', "#{base_string}%" ) }
  scope :with_type_array, -> (base_array) {where('type IN (?)', base_array ) }
  scope :with_type_contains, -> (base_string) {where('type LIKE ?', "%#{base_string}%" ) }
  scope :not_self, -> (id) {where('id <> ?', id )}

  def is_combination?
    !!/TaxonNameRelationship::(OriginalCombination|Combination|SourceClassifiedAs)/.match(self.type.to_s)
  end

  def aliases
    []
  end

  def self.object_properties
    []
  end

  def self.subject_properties
    []
  end

  # left side
  def self.valid_subject_ranks
    []
  end

  # right_side
  def self.valid_object_ranks
    []
  end

  # disjoint relationships for the taxon as a subject
  def self.disjoint_taxon_name_relationships
    []
  end

  def self.disjoint_subject_classes
    []
  end

  def self.disjoint_object_classes
    []
  end

  def self.assignable
    false
  end

  def self.subject_relationship_name
    self.name.demodulize.underscore.humanize.downcase
  end

  def self.object_relationship_name
    self.name.demodulize.underscore.humanize.downcase
  end

  def type_name
    r = self.type.to_s
    TAXON_NAME_RELATIONSHIP_NAMES.include?(r) ? r : nil
  end

  def type_class=(value)
    write_attribute(:type, value.to_s)
  end

  def type_class
    r = read_attribute(:type).to_s
    r = TAXON_NAME_RELATIONSHIP_NAMES.include?(r) ? r.constantize : r
    r
  end

  protected

  # TODO: ! remove once housekeepign stabilizes
  def assign_houskeeping_if_possible
    if self.subject_taxon_name
      self.creator = self.subject_taxon_name.creator if self.creator.nil?
      self.updater = self.subject_taxon_name.updater if self.updater.nil?
      self.project = self.subject_taxon_name.project if self.project.nil?
    end
  end

  #region Validation

  # TODO: Flesh this out vs. TaxonName#rank_class.  Ensure that FactoryGirl type can be set in postgres branch.
  def validate_type
    if type.nil?
      true
    elsif !TAXON_NAME_RELATIONSHIP_NAMES.include?(type.to_s)
      errors.add(:type, "'#{type}' is not a valid taxon name relationship")
    elsif object_taxon_name.class == Protonym
      errors.add(:type, "'#{type}' is not a valid taxon name relationship") if /TaxonNameRelationship::Combination::/.match(self.type.to_s)
    elsif object_taxon_name.class == Combination
      errors.add(:type, "'#{type}' is not a valid taxon name relationship") unless /TaxonNameRelationship::Combination::/.match(self.type.to_s)
    end
  end

  #TODO: validate, that all the relationships in the table could be linked to relationships in classes (if those had changed)

  def validate_subject_and_object_share_code
    if object_taxon_name.class == Protonym && subject_taxon_name.class == Protonym
      errors.add(:object_taxon_name_id, "The related taxon is from different potentially_validating code") if subject_taxon_name.rank_class.nomenclatural_code != object_taxon_name.rank_class.nomenclatural_code
    end
  end

  def validate_valid_subject_and_object
    if self.subject_taxon_name.nil? || self.object_taxon_name.nil?
      true
    elsif self.object_taxon_name_id == self.subject_taxon_name_id
      errors.add(:object_taxon_name_id, "Taxon should not relate to itself")
    elsif self.subject_taxon_name && self.object_taxon_name
      errors.add(:subject_taxon_name_id, "Rank of the taxon is not compatible with the status") if !self.type_class.valid_subject_ranks.include?(subject_taxon_name.rank_class.to_s)
      if object_taxon_name.class == Protonym
        errors.add(:object_taxon_name_id, "Rank of the taxon is not compatible with the status") if !self.type_class.valid_object_ranks.include?(object_taxon_name.rank_class.to_s)
      else
        errors.add(:object_taxon_name_id, "Rank of the taxon is not compatible with the status") if !self.type_class.valid_object_ranks.include?(object_taxon_name.parent.rank_class.to_s)
      end
    end
  end

  def validate_uniqueness_of_synonym_subject
    if self.subject_taxon_name.nil? || self.object_taxon_name.nil? || self.type.nil?
      true
    elsif /Synonym/.match(self.type_name) && !TaxonNameRelationship.where(subject_taxon_name_id: self.subject_taxon_name_id).with_type_contains('Synonym').not_self(self.id||0).empty?
      errors.add(:subject_taxon_name_id, "Only one synonym relationship is allowed")
    end
  end

  def validate_uniqueness_of_typification_object
    if self.subject_taxon_name.nil? || self.object_taxon_name.nil?
      true
    elsif /Typification/.match(self.type_name) && !TaxonNameRelationship.where(object_taxon_name_id: self.object_taxon_name_id).with_type_contains('Typification').not_self(self.id||0).empty?
      errors.add(:object_taxon_name_id, "Only one type relationship is allowed")
    end
  end

  #endregion

  #region Soft Validation

  def sv_validate_disjoint_relationships
    relationships = TaxonNameRelationship.where_subject_is_taxon_name(self.subject_taxon_name).not_self(self)
    relationships.each  do |i|
      soft_validations.add(:type, "Conflicting with another relationship: '#{i.type_class.subject_relationship_name}'") if self.type_class.disjoint_taxon_name_relationships.include?(i.type_name)
    end
  end

  def sv_validate_disjoint_object
    classifications = self.object_taxon_name.taxon_name_classifications.map{|i| i.type_name}
    disjoint_object_classes = self.type_class.disjoint_object_classes
    compare = disjoint_object_classes & classifications
    compare.each do |i|
      c = i.constantize.class_name
      soft_validations.add(:type, "Relationship conflicting with the status: '#{c}'")
      soft_validations.add(:object_taxon_name_id, "Taxon has a conflicting status: '#{c}'")
    end
  end

  def sv_validate_disjoint_subject
    classifications = self.subject_taxon_name.taxon_name_classifications.map{|i| i.type_name}
    disjoint_subject_classes = self.type_class.disjoint_subject_classes
    compare = disjoint_subject_classes & classifications
    compare.each do |i|
      c = i.constantize.class_name
      soft_validations.add(:type, "Relationship conflicting with the status: '#{c}'")
      soft_validations.add(:subject_taxon_name_id, "Taxon has a conflicting status: '#{c}'")
    end
  end


  #endregion

end
