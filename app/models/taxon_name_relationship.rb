require_dependency Rails.root.to_s + '/app/models/taxon_name_classification.rb'

# A NOMEN https://github.com/SpeciesFileGroup/nomen relationship between two Protonyms.
#
# Unless otherwise noted relationships read left to right, and can be interpreted by inserting "of" after the class name.
#
# For example the triple:
#
#    Subject: Aus aus - TaxonNameRelationship::Iczn::Invalidating::Synonym - Object: Bus bus
#
# Can be read as:
#
#    aus synonym OF bus
#
#  Note that not all relationships are reflective.  We can't say, for the example above we can't say
#
#    bus valid_name OF aus
#
# Note that we can not say that all names that are subjects are valid, this is determined on a case by case basis.
#
# TaxonNameRelationships have a domain (attributes on the subject) and range (attributes on the object).  So if you use
# a relationship you may be asserting a TaxonNameClassification also exists for the subject or object.
#
# @todo SourceClassifiedAs is not really Combination in the other sense
# @todo validate, that all the relationships in the table could be linked to relationships in classes (if those had changed)
# @todo Check if more than one species associated with the genus in the original paper
#
# @!attribute subject_taxon_name_id
#   @return [Integer]
#    the subject taxon name
#
# @!attribute object_taxon_name_id
#   @return [Integer]
#    the object taxon name
#
# @!attribute type
#   @return [String]
#    the relationship/"predicate" between the subject and object taxon names
#
# @!attribute project_id
#   @return [Integer]
#   the project ID
#
class TaxonNameRelationship < ApplicationRecord
  include Housekeeping
  include Shared::Citations
  include Shared::Notes
  include Shared::IsData
  include SoftValidation

  # @return [Boolean, nil]
  #   When true, cached values are not built
  attr_accessor :no_cached

  belongs_to :subject_taxon_name, class_name: 'TaxonName', foreign_key: :subject_taxon_name_id, inverse_of: :taxon_name_relationships # left side
  belongs_to :object_taxon_name, class_name: 'TaxonName', foreign_key: :object_taxon_name_id, inverse_of: :related_taxon_name_relationships # right side

  after_save :set_cached_names_for_taxon_names, unless: -> {self.no_cached}
  after_destroy :set_cached_names_for_taxon_names, unless: -> {self.no_cached}

  # TODO: remove, it's required by STI
  validates_presence_of :type, message: 'Relationship type should be specified'
  
  validates_presence_of :subject_taxon_name, message: 'Missing taxon name on the left side'
  validates_presence_of :object_taxon_name, message: 'Missing taxon name on the right side'

  validates_uniqueness_of :object_taxon_name_id, scope: [:type, :project_id], if: :is_combination?
  validates_uniqueness_of :object_taxon_name_id, scope: [:type, :subject_taxon_name_id, :project_id], unless: :is_combination?

  validate :validate_type, :validate_subject_and_object_are_not_identical

  validate :subject_and_object_in_same_project

  with_options unless: -> {!subject_taxon_name || !object_taxon_name} do |v|
    v.validate :validate_subject_and_object_share_code,
      :validate_uniqueness_of_typification_object,
      #:validate_uniqueness_of_synonym_subject,
      :validate_object_and_subject_both_protonyms,
      :validate_object_must_equal_subject_for_uncertain_placement,
      :validate_subject_and_object_ranks,
      :validate_rank_group
  end

  # TODO: isolate to an include file sensu protonym
  soft_validate(
    :sv_validate_required_relationships,
    set: :validate_required_relationships,
    name: 'Required relationships',
    description: 'Required relationships' )

  soft_validate(
    :sv_validate_disjoint_relationships,
    set: :validate_disjoint_relationships,
    name: 'Conflicting relationships',
    description: 'Detect conflicting relationships' )

  soft_validate(
    :sv_validate_disjoint_object,
    set: :validate_disjoint_object,
    name: 'Conflicting object taxon',
    description: 'Object taxon has a status conflicting with the relationship' )

  soft_validate(
    :sv_validate_disjoint_subject,
    set: :validate_disjoint_subject,
    name: 'Conflicting subject taxon',
    description: 'Subject taxon has a status conflicting with the relationship' )

  soft_validate(
    :sv_specific_relationship,
    set: :specific_relationship,
    name: 'validate relationship',
    description: 'Validate integrity of the relationship, for example, the year applicability range' )

  soft_validate(
    :sv_objective_synonym_relationship,
    set: :objective_synonym_relationship,
    fix: :sv_fix_objective_synonym_relationship,
    name: 'Objective synonym relationship',
    description: 'Objective synonyms should have the same type' )

  soft_validate(
    :sv_synonym_relationship,
    set: :synonym_relationship,
    name: 'Synonym relationship',
    description: 'Validate integrity of synonym relationship' )

  soft_validate(
    :sv_not_specific_relationship,
    set: :not_specific_relationship,
    fix: :sv_fix_not_specific_relationship,
    name: 'Not specific relationship',
    description: 'More specific relationship is preferred, for example "Subjective synonym" instead of "Synonym".' )

  soft_validate(
    :sv_synonym_linked_to_valid_name,
    set: :synonym_linked_to_valid_name,
    fix: :sv_fix_subject_parent_update,
    name: 'Synonym not linked to valid taxon',
    description: 'Synonyms should be linked to valid taxon.' )

  soft_validate(
    :sv_validate_priority,
    set: :validate_priority,
    name: 'Priority validation',
    description: 'Junior synonym should be younger than senior synonym' )

  soft_validate(
    :sv_coordinated_taxa,
    set: :coordinated_taxa,
    fix: :sv_fix_coordinated_subject_taxa,
    name: 'Move relationship to coordinate taxon',
    description: 'Relationship should be moved to the lowest rank coordinate taxon (for example from species to nomynotypical subspecies). It could be updated automatically with the Fix.' )

  soft_validate(
    :sv_coordinated_taxa_object,
    set: :coordinated_taxa,
    fix: :sv_fix_coordinated_object_taxa,
    name: 'Move object relationship to coordinate taxon',
    description: 'Relationship should be moved to the lowest rank coordinate object taxon (for example from species to nomynotypical subspecies). It could be updated automatically with the Fix.')

  scope :where_subject_is_taxon_name, -> (taxon_name) {where(subject_taxon_name_id: taxon_name)}
  scope :where_object_is_taxon_name, -> (taxon_name) {where(object_taxon_name_id: taxon_name)}
  scope :where_object_in_taxon_names, -> (taxon_name_array) {where('"taxon_name_relationships"."object_taxon_name_id" IN (?)', taxon_name_array)}

  scope :with_type_string, -> (type_string) { where(sanitize_sql_array(["taxon_name_relationships.type = '%s'", type_string])) }

  scope :with_type_base, -> (base_string) {where('"taxon_name_relationships"."type" LIKE ?', "#{base_string}%")}
  scope :with_type_contains, -> (base_string) {where('"taxon_name_relationships"."type" LIKE ?', "%#{base_string}%")}

  scope :with_two_type_bases, -> (base_string1, base_string2) {
    where("taxon_name_relationships.type LIKE ? OR taxon_name_relationships.type LIKE ?", "#{base_string1}%", "#{base_string2}%") }

  scope :homonym_or_suppressed, -> {where("taxon_name_relationships.type LIKE 'TaxonNameRelationship::Iczn::Invalidating::Homonym%' OR taxon_name_relationships.type LIKE 'TaxonNameRelationship::Iczn::Invalidating::Suppression::Total'") }
  scope :with_type_array, -> (base_array) {where('taxon_name_relationships.type IN (?)', base_array ) }

  # @return [Array of TaxonNameClassification]
  #  the inferable TaxonNameClassification(s) added to the subject when this relationship is used
  #  !! Not implemented
  def subject_properties
    []
  end

  # @return [Array of TaxonNameClassification]
  #  the inferable TaxonNameClassification(s) added to the subject when this relationship is used
  #  !! Not implmented
  def object_properties
    []
  end

  # @return class
  #   this method calls Module#module_parent
  def self.parent
    self.module_parent
  end

  # @return [Array of NomenclatureRank]
  #   the valid ranks to which the subject name can belong, set in subclasses. (left side)
  def self.valid_subject_ranks
    []
  end

  # @return [Array of NomenclatureRank]
  #   the valid ranks to which the object name can belong, set in subclasses. (right side)
  def self.valid_object_ranks
    []
  end

  # @return [Array of TaxonNameRelationships]
  #   if this relationships is set for the subject, then others in this array should not be used for that subject
  def self.disjoint_taxon_name_relationships
    []
  end

  # TODO: why isn't this disjoint?
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

  # @return [Symbol]
  #   determine the relative age of subject and object
  #   :direct - subject is younger than object
  #   :reverse - object is younger than subject
  def self.nomenclatural_priority
    nil
  end

  # @return [String]
  #    the status inferred by the relationship to the object name
  def object_status
    self.type_name.demodulize.underscore.humanize.downcase.gsub(/\d+/, ' \0 ').squish
  end

  # @return [String]
  #    the status inferred by the relationship to the subject name
  def subject_status
    self.type_name.demodulize.underscore.humanize.downcase.gsub(/\d+/, ' \0 ').squish
  end

  # @return [String]
  #    the connecting word in the relationship from the subject name to object name
  def subject_status_connector_to_object
    ' of'
  end

  # @return [String]
  #    the connecting word in the relationship from the object name to subject name
  def object_status_connector_to_subject
    ' of'
  end

  # @return [String]
  #   a readable fragement combining status and connector
  def subject_status_tag
    subject_status + subject_status_connector_to_object
  end

  # @return [String]
  #   a readable fragement combining status and connector
  def object_status_tag
    object_status + object_status_connector_to_subject
  end

  # @return [String, nil]
  #   the type of this relationship, IF the type is a valid name, else nil
  def type_name
    r = self.type
    TAXON_NAME_RELATIONSHIP_NAMES.include?(r) ? r : nil
  end

  def type_class=(value)
    write_attribute(:type, value.to_s)
  end

  def type_class
    r = read_attribute(:type).to_s
    TAXON_NAME_RELATIONSHIP_NAMES.include?(r) ? r.safe_constantize : nil
  end

  # @return [String, nil]
  #   the NOMEN uri for this type
  def self.nomen_uri
    const_defined?(:NOMEN_URI, false) ? self::NOMEN_URI : nil
  end

  # @return [Time]
  #   effective date of publication, used to determine nomenclatural priorities
  def nomenclature_date
    self.source ? (self.source.cached_nomenclature_date ? self.source.cached_nomenclature_date.to_time : Time.now) : Time.now
  end

  def is_combination?
    !!/TaxonNameRelationship::(OriginalCombination|Combination)/.match(self.type.to_s)
  end

  protected

  def subject_and_object_in_same_project
    if subject_taxon_name && object_taxon_name
      errors.add(:base, 'one name is not in the same project as the other') if subject_taxon_name.project_id != object_taxon_name.project_id
    end
  end

  def validate_type
    # TODO: Remove, handled by STI
    if type && !TAXON_NAME_RELATIONSHIP_NAMES.include?(type.to_s)
      errors.add(:type, "'#{type}' is not a valid taxon name relationship")
    elsif self.type_class && object_taxon_name.class.to_s == 'Protonym' && !self.type_class.valid_object_ranks.include?(object_taxon_name.rank_string)
      errors.add(:type, "'#{type}' is not a valid taxon name relationship")
    end

    if object_taxon_name.class.to_s == 'Protonym' || object_taxon_name.class.to_s == 'Hybrid'
      errors.add(:type, "'#{type}' is not a valid taxon name relationship") if /TaxonNameRelationship::Combination::/.match(self.type)
    end

    if object_taxon_name.class.to_s == 'Combination'
      errors.add(:type, "'#{type}' is not a valid taxon name relationship") unless /TaxonNameRelationship::Combination::/.match(self.type)
    end
  end

  # @todo validate, that all the relationships in the table could be linked to relationships in classes (if those had changed)

  def validate_subject_and_object_share_code
    if object_taxon_name.type  == 'Protonym' && subject_taxon_name.type == 'Protonym'
      errors.add(:object_taxon_name_id, 'The related taxon is not in the same monenclatural group (ICZN, ICN, ICNP, ICVCN') if subject_taxon_name.rank_class.try(:nomenclatural_code) != object_taxon_name.rank_class.try(:nomenclatural_code)
    end
  end

  def validate_subject_and_object_are_not_identical
    if !self.object_taxon_name_id.nil? && self.object_taxon_name == self.subject_taxon_name
      errors.add(:object_taxon_name_id, "#{self.object_taxon_name.try(:cached_html).to_s} should not refer to itself") unless self.type =~ /OriginalCombination/
    end
  end

  def validate_object_must_equal_subject_for_uncertain_placement
    if self.object_taxon_name_id != self.subject_taxon_name.parent_id && self.type_name == 'TaxonNameRelationship::Iczn::Validating::UncertainPlacement'
      errors.add(:object_taxon_name_id, "The parent #{self.subject_taxon_name.parent.cached_html} and the Incertae Sedis placement (#{self.object_taxon_name.cached_html}) should match")
    end
  end

  def validate_subject_and_object_ranks
    tname = self.type_name

    if tname =~ /TaxonNameRelationship::(Icnp|Icn|Iczn|Icvcn)/ && tname != 'TaxonNameRelationship::Iczn::Validating::UncertainPlacement'
      rank_group = self.subject_taxon_name.rank_class.try(:parent)
      unless rank_group == self.object_taxon_name.rank_class.try(:parent)
        errors.add(:object_taxon_name_id, "Rank of related taxon should be in the #{rank_group.try(:rank_name)} rank group, not #{self.object_taxon_name.rank_class.try(:rank_name)}")
      end
    end

    unless self.type_class.blank? # only validate if it is set
      if object_taxon_name
        if object_taxon_name.type == 'Protonym' || object_taxon_name.type == 'Hybrid'
          unless self.type_class.valid_object_ranks.include?(self.object_taxon_name.rank_string)
            errors.add(:object_taxon_name_id, "#{self.object_taxon_name.rank_class.rank_name.capitalize} rank of #{self.object_taxon_name.cached_html} is not compatible with the #{self.subject_status} relationship")
            errors.add(:type, "Relationship #{self.subject_status} is not compatible with the #{self.object_taxon_name.rank_class.rank_name} rank of #{self.object_taxon_name.cached_html}")
          end
        end
      end

      if subject_taxon_name
        if subject_taxon_name.type == 'Protonym' || subject_taxon_name.type == 'Hybrid'
          unless self.type_class.valid_subject_ranks.include?(self.subject_taxon_name.rank_string)
            soft_validations.add(:subject_taxon_name_id, "#{self.subject_taxon_name.rank_class.rank_name.capitalize} rank of #{self.subject_taxon_name.cached_html} is not compatible with the #{self.subject_status} relationship")
            soft_validations.add(:type, "Relationship #{self.subject_status} is not compatible with the #{self.subject_taxon_name.rank_class.rank_name} rank of #{self.subject_taxon_name.cached_html}")
          end
        end
      end
    end
  end

  ##### Protonym historically could be listed as a synonym to different taxa
  #def validate_uniqueness_of_synonym_subject
  #  if !self.type.nil? && /Synonym/.match(self.type_name) && !TaxonNameRelationship.where(subject_taxon_name_id: self.subject_taxon_name_id).with_type_contains('Synonym').not_self(self).empty?
  #    errors.add(:subject_taxon_name_id, 'Only one synonym relationship is allowed')
  #  end
  #end

  def validate_uniqueness_of_typification_object
    if /Typification/.match(self.type_name) && !TaxonNameRelationship.where(object_taxon_name_id: self.object_taxon_name_id).with_type_contains('Typification').not_self(self).empty?
      errors.add(:object_taxon_name_id, 'Only one Type designation relationship is allowed')
    end
  end

  def validate_rank_group
    if self.type =~ /Hybrid/ && self.subject_taxon_name && self.object_taxon_name
      if self.subject_taxon_name.rank_class.parent != self.object_taxon_name.rank_class.parent
        errors.add(:subject_taxon_name_id, "#{self.subject_taxon_name.rank_class.rank_name.capitalize} rank of #{self.subject_taxon_name.cached_html} is not compatible with the rank of hybrid (#{self.object_taxon_name.rank_class.rank_name})")
      end
    end
  end

  def validate_object_and_subject_both_protonyms
    if /TaxonNameRelationship::Combination::/.match(self.type)
      errors.add(:object_taxon_name_id, 'Not a Combination') if object_taxon_name.type != 'Combination'
    else
      errors.add(:object_taxon_name_id, 'Not a Protonym') if object_taxon_name.type == 'Combination'
    end
    errors.add(:subject_taxon_name_id, 'Not a Protonym') if subject_taxon_name.type == 'Combination' && self.type != 'TaxonNameRelationship::CurrentCombination'
  end

  def set_cached_names_for_taxon_names
    begin
      TaxonName.transaction do
        if is_invalidating?
          t = subject_taxon_name

          if type_name =~/Misspelling/
            t.update_column(:cached_misspelling, t.get_cached_misspelling)
            t.update_columns(
                cached_author_year: t.get_author_and_year,
                cached_nomenclature_date: t.nomenclature_date,
                cached_original_combination: t.get_original_combination,
                cached_original_combination_html: t.get_original_combination_html
            )
          end

          if type_name =~/Misapplication/
            t.update_columns(
              cached_author_year: t.get_author_and_year,
              cached_nomenclature_date: t.nomenclature_date)
          end

          vn = t.get_valid_taxon_name

          n = t.get_full_name
          t.update_columns(
            cached: n,
            cached_html: t.get_full_name_html(n), # OK to force reload here, otherwise we need an exception in #set_cached
            cached_valid_taxon_name_id: vn.id,
            cached_is_valid: !t.unavailable_or_invalid?)
          t.combination_list_self.each do |c|
            c.update_column(:cached_valid_taxon_name_id, vn.id)
          end

          vn.list_of_invalid_taxon_names.each do |s|
            s.update_columns(
              cached_valid_taxon_name_id: vn.id,
              cached_is_valid: !s.unavailable_or_invalid?)
            s.combination_list_self.each do |c|
              c.update_column(:cached_valid_taxon_name_id, vn.id)
            end
          end
        end
      end
    end
    true
  end

  def is_invalidating?
    TAXON_NAME_RELATIONSHIP_NAMES_INVALID.include?(type_name)
  end

  def sv_validate_required_relationships
    return true if self.subject_taxon_name.not_binominal?
    object_relationships = TaxonNameRelationship.where_object_is_taxon_name(self.object_taxon_name).not_self(self).collect{|r| r.type}
    required = self.type_class.required_taxon_name_relationships - object_relationships
    required.each do |r|
      soft_validations.add(:type, " Presence of #{self.subject_status} requires selection of #{r.demodulize.underscore.humanize.downcase}")
    end
  end

  def sv_validate_disjoint_relationships
    tname = self.type_name
    if tname =~ /TaxonNameRelationship::(Icnp|Icn|Iczn|Icvcn)/ && tname != 'TaxonNameRelationship::Iczn::Validating::UncertainPlacement'
      subject_relationships = TaxonNameRelationship.where_subject_is_taxon_name(self.subject_taxon_name).not_self(self)
      subject_relationships.each  do |i|
        if self.type_class.disjoint_taxon_name_relationships.include?(i.type_name)
          soft_validations.add(:type, "#{self.subject_status.capitalize} relationship is conflicting with another relationship: '#{i.subject_status}'")
        end
      end
    end
  end

  def sv_validate_disjoint_object
    classifications = self.object_taxon_name.taxon_name_classifications.reload.map {|i| i.type_name}
    disjoint_object_classes = self.type_class.disjoint_object_classes
    compare = disjoint_object_classes & classifications
    compare.each do |i|
      c = i.demodulize.underscore.humanize.downcase
      soft_validations.add(:type, "#{self.subject_status.capitalize} relationship is conflicting with the taxon status: '#{c}'")
      soft_validations.add(:object_taxon_name_id, "#{self.object_taxon_name.cached_html} has a conflicting status: '#{c}'")
    end
  end

  def sv_validate_disjoint_subject
    classifications = self.subject_taxon_name.taxon_name_classifications.reload.map {|i| i.type_name}
    disjoint_subject_classes = self.type_class.disjoint_subject_classes
    compare = disjoint_subject_classes & classifications
    compare.each do |i|
      c = i.demodulize.underscore.humanize.downcase
      soft_validations.add(:type, "#{self.subject_status.capitalize} conflicting with the status: '#{c}'")
      soft_validations.add(:subject_taxon_name_id, "#{self.subject_taxon_name.cached_html} has a conflicting status: '#{c}'")
    end
  end

  def sv_specific_relationship
    true # all validations moved to subclasses
  end

  def sv_objective_synonym_relationship
    true # all validations moved to subclasses
  end

  def sv_fix_objective_synonym_relationship
    true # all validations moved to subclasses
  end

  def sv_synonym_relationship
    true # all validations moved to subclasses
  end

  def sv_not_specific_relationship
    true # all validations moved to subclasses
  end

  def sv_fix_not_specific_relationship
    true # all validations moved to subclasses
  end

  def sv_synonym_linked_to_valid_name
    #synonyms and misspellings should be linked to valid names
    if TAXON_NAME_RELATIONSHIP_NAMES_SYNONYM.include?(self.type_name)
      obj = self.object_taxon_name
      subj = self.subject_taxon_name
      if subj.rank_class.try(:nomenclatural_code) == :iczn && (obj.parent_id != subj.parent_id || obj.rank_class != subj.rank_class) &&  subj.cached_valid_taxon_name_id == obj.cached_valid_taxon_name_id
        soft_validations.add(:subject_taxon_name_id, "#{self.subject_status.capitalize}  #{subj.cached_html_name_and_author_year} should have the same parent and rank with  #{obj.cached_html_name_and_author_year}",
                             success_message: 'The parent was updated', failure_message:  'The parent was not updated')
      end
    end
  end

  def sv_fix_subject_parent_update
    res = false
    if TAXON_NAME_RELATIONSHIP_NAMES_SYNONYM.include?(self.type_name)
      obj = self.object_taxon_name
      subj = self.subject_taxon_name
      unless obj.parent_id == subj.parent_id
        subj.parent_id = obj.parent_id
        subj.rank_class = obj.rank_class
        begin
          TaxonName.transaction do
            subj.save!
            res = true
          end
        rescue
        end
      end
    end
    res
  end

  def subject_invalid_statuses
    TAXON_NAME_CLASS_NAMES_UNAVAILABLE_AND_INVALID & self.subject_taxon_name.taxon_name_classifications.collect{|c| c.type_class.to_s}
  end

  def sv_validate_priority
    true # all validations moved to subclasses
  end

  def sv_coordinated_taxa
    s = subject_taxon_name
    o = object_taxon_name
    s_new = s.lowest_rank_coordinated_taxon
    if s != s_new
      soft_validations.add(:subject_taxon_name_id, "Relationship should move from #{s.rank_class.rank_name} #{s.cached_html} to #{s_new.rank_class.rank_name} #{s_new.cached_html}",
                           success_message: "Relationship moved to  #{s_new.rank_class.rank_name}", failure_message:  'Failed to update relationship')
    end
  end

  def sv_coordinated_taxa_object
    s = subject_taxon_name
    o = object_taxon_name
    o_new = o.lowest_rank_coordinated_taxon
    if o != o_new && type_name != 'TaxonNameRelationship::Iczn::Validating::UncertainPlacement'
      soft_validations.add(:object_taxon_name_id, "Relationship should move from #{o.rank_class.rank_name} #{o.cached_html} to #{o_new.rank_class.rank_name} #{o_new.cached_html}",
                           success_message: "Relationship moved to  #{o_new.rank_class.rank_name}", failure_message:  'Failed to update relationship')
    end
  end

  def sv_fix_coordinated_subject_taxa
    s = subject_taxon_name
    s_new = s.lowest_rank_coordinated_taxon
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

  def sv_fix_coordinated_object_taxa
    o = self.object_taxon_name
    o_new = o.lowest_rank_coordinated_taxon
    if o != o_new
      self.object_taxon_name = o_new
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
    if s.rank_string =~ /Species/
      s_new = list.detect{|t| t.rank_class.rank_name == 'species'}
    elsif s.rank_string =~ /Genus/
      s_new = list.detect{|t| t.rank_class.rank_name == 'genus'}
    else
      s_new = s
    end
    if s != s_new && !s.nil?
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

Dir[Rails.root.to_s + '/app/models/taxon_name_relationship/**/*.rb'].each { |file| require_dependency file }
