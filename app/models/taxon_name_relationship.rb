class TaxonNameRelationship < ActiveRecord::Base

  include Housekeeping
  include Shared::Citable
  include SoftValidation

  belongs_to :subject_taxon_name, class_name: 'TaxonName', foreign_key: :subject_taxon_name_id # left side
  belongs_to :object_taxon_name, class_name: 'TaxonName', foreign_key: :object_taxon_name_id   # right side
  belongs_to :source

  soft_validate(:sv_validate_disjoint_relationships, set: :validate_disjoint_relationships)
  soft_validate(:sv_validate_disjoint_object, set: :validate_disjoint_object)
  soft_validate(:sv_validate_disjoint_subject, set: :validate_disjoint_subject)
  soft_validate(:sv_specific_relationship, set: :specific_relationship)
  soft_validate(:sv_objective_synonym_relationship, set: :objective_synonym_relationship)
  soft_validate(:sv_synonym_relationship, set: :synonym_relationship)
  soft_validate(:sv_not_specific_relationship, set: :not_specific_relationship)
  soft_validate(:sv_matching_types, set: :matching_types)
  soft_validate(:sv_synonym_linked_to_valid_name, set: :synonym_linked_to_valid_name)
  soft_validate(:sv_matching_type_genus, set: :matching_type_genus)

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

  def self.priority
    nil # :direct - for subject is younger than object; :reverse - for object is younger than subject
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
    elsif object_taxon_name.class.to_s == 'Protonym'
      errors.add(:type, "'#{type}' is not a valid taxon name relationship") if /TaxonNameRelationship::Combination::/.match(self.type.to_s)
    elsif object_taxon_name.class.to_s == 'Combination'
      errors.add(:type, "'#{type}' is not a valid taxon name relationship") unless /TaxonNameRelationship::Combination::/.match(self.type.to_s)
    end
  end

  #TODO: validate, that all the relationships in the table could be linked to relationships in classes (if those had changed)

  def validate_subject_and_object_share_code
    if object_taxon_name.class.to_s == 'Protonym' && subject_taxon_name.class.to_s == 'Protonym'
      errors.add(:object_taxon_name_id, 'The related taxon is from different potentially_validating code') if subject_taxon_name.rank_class.nomenclatural_code != object_taxon_name.rank_class.nomenclatural_code
    end
  end

  def validate_valid_subject_and_object
    if self.subject_taxon_name.nil? || self.object_taxon_name.nil?
      true
    elsif self.object_taxon_name_id == self.subject_taxon_name_id
      errors.add(:object_taxon_name_id, "Taxon should not relate to itself")
    elsif self.subject_taxon_name && self.object_taxon_name
      errors.add(:subject_taxon_name_id, "Rank of the taxon is not compatible with the status") unless self.type_class.valid_subject_ranks.include?(subject_taxon_name.rank_class.to_s)
      if object_taxon_name.class.to_s == 'Protonym'
        errors.add(:object_taxon_name_id, "Rank of the taxon is not compatible with the status") unless self.type_class.valid_object_ranks.include?(object_taxon_name.rank_class.to_s)
      else
        errors.add(:object_taxon_name_id, "Rank of the taxon is not compatible with the status") unless self.type_class.valid_object_ranks.include?(object_taxon_name.parent.rank_class.to_s)
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

  def sv_specific_relationship
    #TODO update to cover type specimens synonym is objective if type the same or subjective if type is different
    #TODO validate that homonyms spelled identically with variable spelling
    s = self.subject_taxon_name
    o = self.object_taxon_name
    case self.type_name
      when 'TaxonNameRelationship::Iczn::Invalidating::Synonym::Subjective' || 'TaxonNameRelationship::Icn::Unaccepting::Synonym::Heterotypic'
        soft_validations.add(:type, 'Subjective synonyms should not have the same type') if s.type_taxon_name == o.type_taxon_name && !s.type_taxon_name.nil?
      when 'TaxonNameRelationship::Iczn::Invalidating::Homonym::Primary'
        soft_validations.add(:type, 'Primary homonyms should have the same original genus') if s.original_combination_genus != o.original_combination_genus
      when 'TaxonNameRelationship::Iczn::Invalidating::Homonym::Secondary'
        if s.original_combination_genus == o.original_combination_genus && !s.original_combination_genus.nil?
          soft_validations.add(:type, "Both species described in the same genus, they are 'primary homonyms'")
        elsif s.get_valid_taxon_name.ancestor_at_rank('genus') != o.get_valid_taxon_name.ancestor_at_rank('genus')
          soft_validations.add(:type, "Secondary homonyms should be placed in the same genus, the homonymy should be deleted or changed to 'secondary homonym replaced before 1961'")
        end
      when 'TaxonNameRelationship::Iczn::Invalidating::Homonym::Secondary::Secondary1961'
        soft_validations.add(:type, 'Taxon was not described before 1961') if s.year_of_publication > 1960
        soft_validations.add(:type, "Both species described in the same genus, they are 'primary homonyms'") if s.original_combination_genus == o.original_combination_genus && !s.original_combination_genus.nil?
        soft_validations.add(:source_id, 'Source is not selected') if self.source_id.nil?
        if !!self.source_id
          soft_validations.add(:source_id, 'Taxon should be treated a homonym before 1961') if self.source.year > 1960
        end
      when 'TaxonNameRelationship::Typification::Genus::SubsequentDesignation'
        soft_validations.add(:source_id, 'Source is not selected') if self.source_id.nil?
      when 'TaxonNameRelationship::Iczn::PotentiallyValidating::FamilyBefore1961'
        soft_validations.add(:type, 'Taxon was not described before 1961') if s.year_of_publication > 1960
        if !!self.source_id
          soft_validations.add(:source_id, 'Taxon should be accepted as a replacement name before 1961') if self.source.year > 1960
        end
    end
  end

  def sv_objective_synonym_relationship
    if self.type_name =~ /TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective/ || self.type_name =~ /TaxonNameRelationship::Icn::Unaccepting::Synonym::Homotypic/
      soft_validations.add(:type, 'Objective synonyms should have the same type') if self.subject_taxon_name.type_taxon_name != self.object_taxon_name.type_taxon_name
    end
  end

  def sv_synonym_relationship
    if TAXON_NAME_RELATIONSHIP_NAMES_INVALID.include?(self.type_name)
      if !!self.source_id
        date1 = self.source.nomenclature_date.to_time
        date2 = self.subject_taxon_name.nomenclature_date
        if !!date1 && !!date2
          soft_validations.add(:source_id, 'Taxon was not described at the time of citation') if date2 - date1 > 0
        end
      else
        soft_validations.add(:source_id, 'Source is not selected')
      end
    end
  end

  def sv_not_specific_relationship
    case self.type_name
      when 'TaxonNameRelationship::Typification::Genus'
        soft_validations.add(:type, 'Please specify if the type designation is original or subsequent')
      when 'TaxonNameRelationship::Typification::Genus::Monotypy'
        soft_validations.add(:type, 'Please specify if the monotypy is original or subsequent')
      when 'TaxonNameRelationship::Typification::Genus::Tautonomy'
        soft_validations.add(:type, 'Please specify if the tautonomy is absolute or Linnaean')
      when 'TaxonNameRelationship::Icn::Unaccepting'
        soft_validations.add(:type, 'Please specify the reasons why the name is Unaccepted')
      when 'TaxonNameRelationship::Icn::Unaccepting::Synonym'
        soft_validations.add(:type, 'Please specify if this is a homotypic or heterotypic synonym',
            fix: :sv_fix_specify_synonymy_type, success_message: 'Synonym updated to being homotypic or heterotypic')
      when 'TaxonNameRelationship::Iczn::Invalidating'
        soft_validations.add(:type, 'Please specify the reason why the name is Invalid')
      when 'TaxonNameRelationship::Iczn::Invalidating::Homonym'
        if NomenclaturalRank::Iczn::SpeciesGroup.descendants.collect{|t| t.to_s}.include?(self.subject_taxon_name.rank_class.to_s)
          soft_validations.add(:type, 'Please specify if this is a primary or secondary homonym',
              fix: :sv_fix_specify_homonymy_type, success_message: 'Homonym updated to being primary or secondary')
        end
      when 'TaxonNameRelationship::Iczn::Invalidating::Synonym'
        soft_validations.add(:type, 'Please specify if this is a objective or subjective synonym',
            fix: :sv_fix_specify_synonymy_type, success_message: 'Synonym updated to being objective or subjective')
      when 'TaxonNameRelationship::Iczn::Invalidating::Synonym::Suppression'
        soft_validations.add(:type, 'Please specify if this is a total, partial, or conditional suppression')
    end
  end

  def sv_fix_specify_synonymy_type
    #TODO update to cover type specimens synonym is objective if type the same or subjective if type is different
    subject_type = self.subject_taxon_name.type_taxon_name
    object_type = self.object_taxon_name.type_taxon_name
    new_relationship_name = self.type_name
    if subject_type == object_type && !subject_type.nil?
      if new_relationship_name == 'TaxonNameRelationship::Iczn::Invalidating::Synonym'
        new_relationship_name = 'TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective'
      else
        new_relationship_name = 'TaxonNameRelationship::Icn::Unaccepting::Synonym::Homotypic'
      end
    elsif subject_type != object_type && !subject_type.nil?
      if new_relationship_name == 'TaxonNameRelationship::Iczn::Invalidating::Synonym'
        new_relationship_name = 'TaxonNameRelationship::Iczn::Invalidating::Synonym::Subjective'
      else
        new_relationship_name = 'TaxonNameRelationship::Icn::Unaccepting::Synonym::Heterotypic'
      end
    end
    if self.type_name != new_relationship_name
      self.type = new_relationship_name
      begin
        TaxonNameRelationship.transaction do
          self.save
          return true
        end
      rescue
      end
    end

    false
  end

  def sv_fix_specify_homonymy_type
    subject_original_genus = self.subject_taxon_name.original_combination_genus
    object_original_genus = self.object_taxon_name.original_combination_genus
    subject_genus = self.subject_taxon_name.ancestor_at_rank('genus')
    object_genus = self.subject_taxon_name.ancestor_at_rank('genus')
    new_relationship_name = 'nil'
    if subject_original_genus == object_original_genus && !subject_original_genus.nil?
      new_relationship_name = 'TaxonNameRelationship::Iczn::Invalidating::Homonym::Primary'
    elsif subject_genus != object_genus && !subject_genus.nil?
      new_relationship_name = 'TaxonNameRelationship::Iczn::Invalidating::Homonym::Secondary'
    end
    if self.type_name != new_relationship_name
      self.type = new_relationship_name
      begin
        TaxonNameRelationship.transaction do
          self.save
          return true
        end
      rescue
      end
    end
    false
  end

  def sv_synonym_linked_to_valid_name
    #synonyms and misspellings should be linked to valid names
    if TAXON_NAME_RELATIONSHIP_NAMES_INVALID.include?(self.type_name)
      obj = self.object_taxon_name
      if obj.get_valid_taxon_name != obj
        soft_validations.add(:object_taxon_name_id, "The #{self.type_class.subject_relationship_name} should be associated with a valid name",
                             fix: :sv_fix_synonym_linked_to_valid_name, success_message: 'The associated taxon was updated')
      end
    end
  end

  def sv_fix_synonym_linked_to_valid_name
    if TAXON_NAME_RELATIONSHIP_NAMES_INVALID.include?(self.type_name)
      obj = self.object_taxon_name
      if obj.get_valid_taxon_name != obj
        self.object_taxon_name = obj.get_valid_taxon_name
        begin
          TaxonName.transaction do
            self.save
            return true
          end
        rescue
        end
      end
    end
    false
  end

  def sv_matching_type_genus
    if self.type_name == 'TaxonNameRelationship::Typification::Family'
      if self.object_taxon_name.name.slice(0, 1) != self.subject_taxon_name.name.slice(0, 1)
        soft_validations.add(:object_taxon_name_id, 'Type genus should have the same initial letters as the family-group name')
      end
    end
  end

  #endregion

end
