# A NOMEN based relationship between two Protonyms.
#
class TaxonNameRelationship < ActiveRecord::Base
  include Housekeeping
  include Shared::Citable
  include Shared::IsData
  include SoftValidation

  belongs_to :subject_taxon_name, class_name: 'TaxonName', foreign_key: :subject_taxon_name_id # left side
  belongs_to :object_taxon_name, class_name: 'TaxonName', foreign_key: :object_taxon_name_id   # right side
  belongs_to :source

  validates_presence_of :type, message: 'Relationship type should be specified'
  validates_presence_of :subject_taxon_name_id, message: 'Taxon is not selected'
  validates_presence_of :object_taxon_name_id, message: 'Taxon is not selected'
  validates_uniqueness_of :object_taxon_name_id, scope: :type, if: :is_combination?
  validates_uniqueness_of :object_taxon_name_id, scope: [:type, :subject_taxon_name_id], unless: :is_combination?

  validate :validate_type, :validate_subject_and_object_are_not_identical

  with_options unless: '!subject_taxon_name || !object_taxon_name' do |v|
    v.validate :validate_subject_and_object_share_code,
      :validate_uniqueness_of_typification_object,
      :validate_uniqueness_of_synonym_subject,
      :validate_object_must_equal_subject_for_uncertain_placement,
      :validate_subject_and_object_ranks
  end

  soft_validate(:sv_validate_required_relationships, set: :validate_required_relationships)
  soft_validate(:sv_validate_disjoint_relationships, set: :validate_disjoint_relationships)
  soft_validate(:sv_validate_disjoint_object, set: :validate_disjoint_object)
  soft_validate(:sv_validate_disjoint_subject, set: :validate_disjoint_subject)
  soft_validate(:sv_specific_relationship, set: :specific_relationship)
  soft_validate(:sv_objective_synonym_relationship, set: :objective_synonym_relationship)
  soft_validate(:sv_synonym_relationship, set: :synonym_relationship)
  soft_validate(:sv_not_specific_relationship, set: :not_specific_relationship)
  soft_validate(:sv_synonym_linked_to_valid_name, set: :synonym_linked_to_valid_name)
  soft_validate(:sv_matching_type_genus, set: :matching_type_genus)
  soft_validate(:sv_validate_priority, set: :validate_priority)
  soft_validate(:sv_validate_homonym_relationships, set: :validate_homonym_relationships)
  soft_validate(:sv_coordinated_taxa, set: :coordinated_taxa)
  # @proceps: this method doesn't seem to exist:  soft_validate(:sv_matching_types, set: :matching_types)

  scope :where_subject_is_taxon_name, -> (taxon_name) {where(subject_taxon_name_id: taxon_name)}
  scope :where_object_is_taxon_name, -> (taxon_name) {where(object_taxon_name_id: taxon_name)}
  scope :where_object_in_taxon_names, -> (taxon_name_array) {where('object_taxon_name_id IN (?)', taxon_name_array)}
  scope :with_type_string, -> (type_string) {where('type LIKE ?', "#{type_string}" ) }
  scope :with_type_base, -> (base_string) {where('type LIKE ?', "#{base_string}%" ) }
  scope :with_two_type_bases, -> (base_string1, base_string2) {where("type LIKE '#{base_string1}%' OR type LIKE '#{base_string2}%'" ) }
  scope :with_type_array, -> (base_array) {where('type IN (?)', base_array ) }
  scope :with_type_contains, -> (base_string) {where('type LIKE ?', "%#{base_string}%" ) }
  scope :not_self, -> (id) {where('id <> ?', id )}

  # TODO: SourceClassifiedAs is not really Combination in the other sense
  def is_combination?
    !!/TaxonNameRelationship::(OriginalCombination|Combination|SourceClassifiedAs)/.match(self.type) 
  end.to_s

  def aliases
    []
  end

  def object_properties
    []
  end

  def subject_properties
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

  # disjoint relationships for the taxon as a object
  def self.required_taxon_name_relationships
    []
  end

  def self.disjoint_subject_classes
    []
  end

  def self.disjoint_object_classes
    []
  end

  def self.gbif_status_of_subject
    nil
  end

  def self.gbif_status_of_object
    nil
  end

  def self.assignable
    false
  end

  def self.nomenclatural_priority
    nil # :direct - for subject is younger than object; :reverse - for object is younger than subject
  end

  def self.subject_relationship_name
    self.name.demodulize.underscore.humanize.downcase
  end

  def self.object_relationship_name
    self.name.demodulize.underscore.humanize.downcase
  end

  def type_name
    r = self.type
    TAXON_NAME_RELATIONSHIP_NAMES.include?(r) ? r : nil
  end

  def type_class=(value)
    write_attribute(:type, value.to_s)
  end

  def type_class
    r = read_attribute(:type).to_s
    r = TAXON_NAME_RELATIONSHIP_NAMES.include?(r) ? r.safe_constantize : r
    r
  end

  protected

  #region Validation

  def validate_type
    if !TAXON_NAME_RELATIONSHIP_NAMES.include?(type)
      errors.add(:type, "'#{type}' is not a valid taxon name relationship")
    end

    if object_taxon_name.class.to_s == 'Protonym'
      errors.add(:type, "'#{type}' is not a valid taxon name relationship") if /TaxonNameRelationship::Combination::/.match(self.type)
    end

    if object_taxon_name.class.to_s == 'Combination'
      errors.add(:type, "'#{type}' is not a valid taxon name relationship") unless /TaxonNameRelationship::Combination::/.match(self.type)
    end
  end

  #TODO: validate, that all the relationships in the table could be linked to relationships in classes (if those had changed)

  def validate_subject_and_object_share_code
    if object_taxon_name.type  == 'Protonym' && subject_taxon_name.type == 'Protonym'
      errors.add(:object_taxon_name_id, 'The related taxon is from different potentially_validating code') if subject_taxon_name.rank_class.nomenclatural_code != object_taxon_name.rank_class.nomenclatural_code
    end
  end

  def validate_subject_and_object_are_not_identical
    if self.object_taxon_name_id == self.subject_taxon_name_id
      errors.add(:object_taxon_name_id, 'Taxon should not refer to itself')
    end
  end

  def validate_object_must_equal_subject_for_uncertain_placement
    if self.object_taxon_name_id != self.subject_taxon_name.parent_id && self.type_name == 'TaxonNameRelationship::Iczn::Validating::UncertainPlacement'
      errors.add(:object_taxon_name_id, 'The parent and related taxon should match')
    end
  end

  def validate_subject_and_object_ranks
    tname = self.type_name
    if TAXON_NAME_RELATIONSHIP_NAMES.include?(tname)
      unless self.type_class.valid_subject_ranks.include?(self.subject_taxon_name.rank_class.to_s)
        errors.add(:subject_taxon_name_id, "The rank of taxon is not compatible with relationship '#{self.type_class.object_relationship_name}'")
        errors.add(:type, 'Not compatible with the rank of this taxon')
      end
    end

    if tname =~ /TaxonNameRelationship::(Icn|Iczn)/ && tname != 'TaxonNameRelationship::Iczn::Validating::UncertainPlacement'
      rank_group = self.subject_taxon_name.rank_class.parent
      unless rank_group == self.object_taxon_name.rank_class.parent
        errors.add(:object_taxon_name_id, "Rank of related taxon should be in the #{rank_group.rank_name}")
      end
    end

    if object_taxon_name
      if object_taxon_name.type == 'Protonym'
        unless self.type_class.valid_object_ranks.include?(self.object_taxon_name.rank_class.to_s)
          errors.add(:object_taxon_name_id, 'Rank of the taxon is not compatible with the status')
          errors.add(:type, 'Not compatible with the rank of related taxon')
        end
      end

      if object_taxon_name.type == 'Combination'
        unless self.type_class.valid_object_ranks.include?(self.object_taxon_name.parent.rank_class.to_s)
          soft_validations.add(:object_taxon_name_id, 'Rank of the taxon is not compatible with the status')
          soft_validations.add(:type, 'Not compatible with the rank of related taxon')
        end
      end
    end
  end

  def validate_uniqueness_of_synonym_subject
    if !self.type.nil? && /Synonym/.match(self.type_name) && !TaxonNameRelationship.where(subject_taxon_name_id: self.subject_taxon_name_id).with_type_contains('Synonym').not_self(self.id||0).empty?
      errors.add(:subject_taxon_name_id, 'Only one synonym relationship is allowed')
    end
  end

  def validate_uniqueness_of_typification_object
    if /Typification/.match(self.type_name) && !TaxonNameRelationship.where(object_taxon_name_id: self.object_taxon_name_id).with_type_contains('Typification').not_self(self.id||0).empty?
      errors.add(:object_taxon_name_id, 'Only one type relationship is allowed')
    end
  end

  #endregion

  #region Soft Validation

  def sv_validate_required_relationships
    object_relationships = TaxonNameRelationship.where_object_is_taxon_name(self.object_taxon_name).not_self(self).collect{|r| r.type}
    required = self.type_class.required_taxon_name_relationships - object_relationships
    required.each do |r|
      soft_validations.add(:type, " Presence of #{self.type_class.object_relationship_name} requires selection of #{r.safe_constantize.object_relationship_name}")
    end
  end

  def sv_validate_disjoint_relationships
    subject_relationships = TaxonNameRelationship.where_subject_is_taxon_name(self.subject_taxon_name).not_self(self)
    subject_relationships.each  do |i|
      if self.type_class.disjoint_taxon_name_relationships.include?(i.type_name)
        soft_validations.add(:type, "Conflicting with another relationship: '#{i.type_class.object_relationship_name}'")
      end
    end
  end

  def sv_validate_disjoint_object
    classifications = self.object_taxon_name.taxon_name_classifications.map{|i| i.type_name}
    disjoint_object_classes = self.type_class.disjoint_object_classes
    compare = disjoint_object_classes & classifications
    compare.each do |i|
      c = i.safe_constantize.class_name
      soft_validations.add(:type, "Relationship conflicting with the status: '#{c}'")
      soft_validations.add(:object_taxon_name_id, "Taxon has a conflicting status: '#{c}'")
    end
  end

  def sv_validate_disjoint_subject
    classifications = self.subject_taxon_name.taxon_name_classifications.map{|i| i.type_name}
    disjoint_subject_classes = self.type_class.disjoint_subject_classes
    compare = disjoint_subject_classes & classifications
    compare.each do |i|
      c = i.safe_constantize.class_name
      soft_validations.add(:type, "Relationship conflicting with the status: '#{c}'")
      soft_validations.add(:subject_taxon_name_id, "Taxon has a conflicting status: '#{c}'")
    end
  end

  def sv_specific_relationship
    s = self.subject_taxon_name
    o = self.object_taxon_name
    case self.type_name
      when 'TaxonNameRelationship::Iczn::Invalidating::Synonym::Subjective' || 'TaxonNameRelationship::Icn::Unaccepting::Synonym::Heterotypic'
        if (s.type_taxon_name == o.type_taxon_name && !s.type_taxon_name.nil? ) || (!s.get_primary_type.empty? && s.matching_primary_types(s, o) )
          soft_validations.add(:type, 'Subjective synonyms should not have the same type')
        end
      when 'TaxonNameRelationship::Iczn::Invalidating::Homonym'
        soft_validations.add(:type, 'Names are not similar enough to be homonyms') unless s.cached_primary_homonym_alternative_spelling == o.cached_primary_homonym_alternative_spelling
      when 'TaxonNameRelationship::Iczn::Invalidating::Homonym::Primary'
        if s.original_genus != o.original_genus
          soft_validations.add(:type, 'Primary homonyms should have the same original genus')
        elsif s.cached_primary_homonym_alternative_spelling != o.cached_primary_homonym_alternative_spelling
          soft_validations.add(:type, 'Names are not similar enough to be homonyms')
        end
      when 'TaxonNameRelationship::Iczn::Invalidating::Homonym::Secondary' #!

        if s.original_genus == o.original_genus && !s.original_genus.nil?
          soft_validations.add(:type, "Both species described in the same genus, they are 'primary homonyms'")
        elsif s.get_valid_taxon_name.ancestor_at_rank('genus') != o.get_valid_taxon_name.ancestor_at_rank('genus')
          soft_validations.add(:type, "Secondary homonyms should be placed in the same genus, the homonymy should be deleted or changed to 'secondary homonym replaced before 1961'")
        elsif s.cached_secondary_homonym_alternative_spelling != o.cached_secondary_homonym_alternative_spelling
          soft_validations.add(:type, 'Names are not similar enough to be homonyms')
        end

        if (s.all_generic_placements & o.all_generic_placements).empty?
          soft_validations.add(:base, 'No combination available showing both species placed in the same genus') 
        end

      when 'TaxonNameRelationship::Iczn::Invalidating::Homonym::Secondary::Secondary1961'
       
        soft_validations.add(:type, 'Taxon was not described before 1961') if s.year_of_publication > 1960
        soft_validations.add(:type, "Both species described in the same genus, they are 'primary homonyms'") if s.original_genus == o.original_genus && !s.original_genus.nil?
        soft_validations.add(:source_id, 'Source is not selected') if self.source_id.nil?
       
        if !!self.source_id
          soft_validations.add(:source_id, 'Taxon should be treated a homonym before 1961') if self.source.year > 1960
        end
       
        byebug 
        if (s.all_generic_placements & o.all_generic_placements).empty?
          soft_validations.add(:base, 'No combination available showing both species placed in the same genus') 
        end

      when 'TaxonNameRelationship::Iczn::PotentiallyValidating::FamilyBefore1961'
        soft_validations.add(:type, 'Taxon was not described before 1961') if s.year_of_publication > 1960
        if !!self.source_id
          soft_validations.add(:source_id, 'Taxon should be accepted as a replacement name before 1961') if self.source.year > 1960
        end


      when 'TaxonNameRelationship::Typification::Genus::SubsequentDesignation'
        soft_validations.add(:type, 'Genus described after 1930 is nomen nudum, if type was not designated in the original publication') if o.year_of_publication > 1930
      when 'TaxonNameRelationship::Typification::Genus::Monotypy::Original'
        #TODO: Check if more than one species associated with the genus in the original paper
    end
  end

  def sv_objective_synonym_relationship
    if self.type_name =~ /TaxonNameRelationship::(Iczn::Invalidating::Synonym::Objective|Icn::Unaccepting::Synonym::Homotypic)/
      s = self.subject_taxon_name
      o = self.object_taxon_name
      if (s.type_taxon_name != o.type_taxon_name ) || !s.matching_primary_types(s, o)
        soft_validations.add(:type, 'Objective synonyms should have the same type')
      end
    end
  end

  def sv_synonym_relationship
    relationships = TAXON_NAME_RELATIONSHIP_NAMES_INVALID +
        TaxonNameRelationship.collect_to_s(TaxonNameRelationship::Typification::Genus::SubsequentDesignation,
            TaxonNameRelationship::Typification::Genus::RulingByCommission)
    if relationships.include?(self.type_name)
      if !!self.source_id
        date1 = self.source.cached_nomenclature_date.to_time
        date2 = self.subject_taxon_name.nomenclature_date
        if !!date1 && !!date2
          soft_validations.add(:source_id, 'Taxon was not described at the time of citation') if date2 > date1
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
        soft_validations.add(:type, 'Please specify the reasons for the name being Unaccepted')
      when 'TaxonNameRelationship::Icn::Unaccepting::Synonym'
        soft_validations.add(:type, 'Please specify if this is a homotypic or heterotypic synonym',
            fix: :sv_fix_specify_synonymy_type, success_message: 'Synonym updated to being homotypic or heterotypic')
      when 'TaxonNameRelationship::Iczn::Invalidating'
        soft_validations.add(:type, 'Please specify the reason for the name being Invalid')
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
    s = self.subject_taxon_name
    o = self.object_taxon_name
    subject_type = s.type_taxon_name
    object_type = o.type_taxon_name
    new_relationship_name = self.type_name
    if (subject_type == object_type && !subject_type.nil? ) || (!s.get_primary_type.empty? && s.matching_primary_types(s, o) )
      if new_relationship_name == 'TaxonNameRelationship::Iczn::Invalidating::Synonym'
        new_relationship_name = 'TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective'
      else
        new_relationship_name = 'TaxonNameRelationship::Icn::Unaccepting::Synonym::Homotypic'
      end
    elsif (subject_type != object_type && !subject_type.nil? ) || (!s.get_primary_type.empty? && !o.get_primary_type.empty? && !s.matching_primary_types(s, o))
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
    subject_original_genus = self.subject_taxon_name.original_genus
    object_original_genus = self.object_taxon_name.original_genus
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
      subj = self.subject_taxon_name
      if obj.get_valid_taxon_name != obj
        soft_validations.add(:object_taxon_name_id, "The #{self.type_class.object_relationship_name} should be associated with a valid name",
                             fix: :sv_fix_synonym_linked_to_valid_name, success_message: 'The associated taxon was updated')
      elsif obj.parent_id != subj.parent_id
        soft_validations.add(:subject_taxon_name_id, "The #{self.type_class.object_relationship_name} should have the same parent with the associated taxon",
                             fix: :sv_fix_subject_parent_update, success_message: 'The parent was updated')
      end
    end
  end

  def sv_fix_synonym_linked_to_valid_name
    if TAXON_NAME_RELATIONSHIP_NAMES_INVALID.include?(self.type_name)
      obj = self.object_taxon_name
      unless obj.get_valid_taxon_name == obj
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

  def sv_fix_subject_parent_update
    if TAXON_NAME_RELATIONSHIP_NAMES_INVALID.include?(self.type_name)
      obj = self.object_taxon_name
      subj = self.subject_taxon_name
      unless obj.parent_id == subj.parent_id
        subj.parent_id = obj.parent_id
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

  def sv_validate_priority
    unless self.type_class.nomenclatural_priority.nil?
      date1 = self.subject_taxon_name.nomenclature_date
      date2 = self.object_taxon_name.nomenclature_date
      invalid_statuses = TAXON_NAME_CLASS_NAMES_UNAVAILABLE_AND_INVALID & self.subject_taxon_name.taxon_name_classifications.collect{|c| c.type_class.to_s}
      if self.type_name == 'TaxonNameRelationship::Iczn::PotentiallyValidating::FirstRevisorAction'
        unless date1 == date2
          soft_validations.add(:type, 'Both taxa should be described on the same date')
          soft_validations.add(:object_taxon_name_id, 'Taxon has different publication date')
        end
      elsif !!date1 and !!date2
        case self.type_class.nomenclatural_priority
          when :direct
            if date2 > date1 && invalid_statuses.empty?
              if self.type_name =~ /TaxonNameRelationship::Iczn::Invalidating::Homonym/
                soft_validations.add(:type, "#{self.type_class.subject_relationship_name.capitalize} should not be older than related taxon")
              elsif self.type_name =~ /::Iczn::/ && TaxonNameRelationship.where_subject_is_taxon_name(self.subject_taxon_name).with_two_type_bases('TaxonNameRelationship::Iczn::Invalidating::Homonym', 'TaxonNameRelationship::Iczn::Validating').not_self(self).empty?
                soft_validations.add(:type, "#{self.type_class.subject_relationship_name.capitalize} should not be older than related taxon, unless it is also a homonym or conserved")
              elsif self.type_name =~ /::Icn::/ && TaxonNameRelationship.where_subject_is_taxon_name(self.subject_taxon_name).with_two_type_bases('TaxonNameRelationship::Icn::Accepting::Conserved', 'TaxonNameRelationship::Icn::Accepting::Sanctioned').not_self(self).empty?
                soft_validations.add(:type, "#{self.type_class.subject_relationship_name.capitalize} should not be older than related taxon, unless it is also conserved or sanctioned")
              end
            end
          when :reverse
            if date1 > date2 && invalid_statuses.empty?
              if self.type_name =~ /TaxonNameRelationship::(Typification|Combination|OriginalCombination|SourceClassifiedAs)/
                soft_validations.add(:subject_taxon_name_id, "#{self.type_class.object_relationship_name.capitalize} should not be younger than the taxon")
              else
                soft_validations.add(:type, "#{self.type_class.object_relationship_name.capitalize} should not be younger than related taxon")
              end
            end
        end
      end
    end
  end

  def sv_validate_homonym_relationships
    if self.type_name =~ /TaxonNameRelationship::Iczn::Invalidating::Homonym/
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
    end
  end

  def sv_add_synonym_for_homonym
    if self.type_name =~ /TaxonNameRelationship::Iczn::Invalidating::Homonym/
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
    end
    false
  end

  def sv_coordinated_taxa
    s = self.subject_taxon_name
    o = self.object_taxon_name
    if self.type_name =~ /TaxonNameRelationship::(Iczn|Icn)/
      s_new = s.lowest_rank_coordinated_taxon
      o_new = o.lowest_rank_coordinated_taxon
      if o != o_new && self.subject_taxon_name != 'TaxonNameRelationship::Iczn::Validating::UncertainPlacement'
        soft_validations.add(:object_taxon_name_id, "Relationship should move from #{o.rank_class.rank_name} to #{o_new.rank_class.rank_name}",
                             fix: :sv_fix_coordinated_taxa, success_message: "Relationship moved to  #{o_new.rank_class.rank_name}")
      end
      if s != s_new
        soft_validations.add(:subject_taxon_name_id, "Relationship should move from #{s.rank_class.rank_name} to #{s_new.rank_class.rank_name}",
                             fix: :sv_fix_coordinated_taxa, success_message: "Relationship moved to  #{s_new.rank_class.rank_name}")
      end
    elsif self.type_name =~ /TaxonNameRelationship::(OriginalCombination|Combination|SourceClassifiedAs)/
      list = s.list_of_coordinated_names + [s]
      if s.rank_class.to_s =~ /Species/
        s_new =  list.detect{|t| t.rank_class.rank_name == 'species'}
      elsif s.rank_class.to_s=~ /Genus/
        s_new =  list.detect{|t| t.rank_class.rank_name == 'genus'}
      else
        s_new = s
      end
      if s != s_new
        soft_validations.add(:subject_taxon_name_id, "Relationship should move from #{s.rank_class.rank_name} to #{s_new.rank_class.rank_name}",
                             fix: :sv_fix_combination_relationship, success_message: "Relationship moved to  #{s_new.rank_class.rank_name}")
      end
      end
  end

  def sv_fix_coordinated_taxa
    s = self.subject_taxon_name
    o = self.object_taxon_name
    s_new = s.lowest_rank_coordinated_taxon
    o_new = o.lowest_rank_coordinated_taxon
    if o != o_new || s != s_new
      self.object_taxon_name = o_new
      self.subject_taxon_name = s_new
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

  def sv_fix_combination_relationship
    s = self.subject_taxon_name
    list = s.list_of_coordinated_names + [s]
    if s.rank_class.to_s =~ /Species/
      s_new =  list.detect{|t| t.rank_class.rank_name == 'species'}
    elsif s.rank_class.to_s=~ /Genus/
      s_new =  list.detect{|t| t.rank_class.rank_name == 'genus'}
    else
      s_new = s
    end
    if s != s_new
      self.subject_taxon_name = s_new
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

  #endregion

  private

  def self.collect_to_s(*args)
    args.collect{|arg| arg.to_s}
  end

  def self.collect_descendants_to_s(*classes)
    ans = []
    classes.each do |klass|
      ans += klass.descendants.collect{|k| k.to_s}
    end
    ans    
  end

  def self.collect_descendants_and_itself_to_s(*classes)
    classes.collect{|k| k.to_s} + self.collect_descendants_to_s(*classes)
  end
end
