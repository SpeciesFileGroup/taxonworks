# A taxonomic name (nomenclature only). See also NOMEN.
#
# There are 3 subclasses, Protonym, Combination, and Hybrid.  
#
# @!attribute name
#   @return [String, nil]
#   the fully latinized string (monomimial) of a code governed taxonomic biological name
#   not applicable for Combinations, they are derived from their pieces
#
# @!attribute parent_id
#   @return [Integer]
#   The id of the parent taxon. The parent child relationship is exclusively organizational. All statuses and relationships
#   of a taxon name must be explicitly defined via taxon name relationships or classifications. The parent of a taxon name
#   can be thought of as  "the place where you'd find this name in a hierarchy if you knew literally *nothing* else about that name."
#   In practice read each monomial in the name (protonym or combination) from right to left, the parent is the parent of the last monomial read.
#   There are 3 simple rules for determening the parent of a Protonym or Combination:
#     1) the parent must always be at least one rank higher than the target names rank
#     2) the parent of a synonym (any sense) is the parent of the synonym's valid name
#     3) the parent of a combination is the parent of the highest ranked monomial in the epithet (almost always the parent of the genus)
#
# @!attribute cached_html
#   @return [String]
#   Genus-species combination for the taxon. The string is in html format including <i></i> tags.
#
# @attribute cached_author_year
#   @return [String, nil]
#      author and year string with parentheses where necessary, i.e. with context of present placement for iczn
#
# @!attribute cached_higher_classification
#   @return [String]
#   a concatenated list of higher rank taxa. !! Currently deprecated.
#
# @!attribute year_of_publication
#   @return [Integer]
#    sensu ICZN - the 4 digit year when this name was published, i.e. made available. Not the publishers date stamped on the title page, but the actual date of publication. Precidence for taxon name publication year is TaxonName#year_of_publication, Source#year, Source#stated_year.
#
# @!attribute verbatim_author
#   @return [String]
#   the verbatim author string as provided ? is not post-filled in when Source is referenced !?
#
# @!attribute rank_class
#   @return [String]
#   The TW rank of this name 
#
# @!attribute type
#   @return [String]
#   The subclass of this taxon name, e.g. Protonym or Combination 
#
# @!attribute project_id
#   @return [Integer]
#   the project ID
#
# @!attribute cached_original_combination
#   @return [String]
#   name as formed in original combination.
#
# @!attribute cached_secondary_homonym
#   @return [String]
#   current genus and species name. Used to find and validate secondary homonyms.
#
# @attribute cached_primary_homonym
#   @return [String]
#   original genus and species name. Used to find and validate primary homonyms.
#
# @attribute cached_secondary_homonym_alternative_spelling
#   @return [String]
#   Current genus and species name in alternative spelling. Used to find and validate secondary homonyms.
#
# @!attribute cached_primary_homonym_alternative_spelling
#   @return [String]
#   Original genus and species name in alternative spelling. Used to find and validate primary homonyms.
#
# @!attribute cached_misspelling
#   @return [Boolean]
#   if the name is a misspelling, stores True.
#
# @!attribute masculine_name
#   @return [String]
#   Species name which are adjective or participle change depending on the gender of the genus.
#   3 fields provide alternative species spelling. The part_of_speech is designated as a taxon_name_classification.
#   The gender of a genus also designated as a taxon_name_classification.
#
# @!attribute feminine_name
#   @return [String]
#   Species name which are adjective or participle change depending on the gender of the genus.
#   3 fields provide alternative species spelling. The part_of_speech is designated as a taxon_name_classification.
#   The gender of a genus also designated as a taxon_name_classification.
#
# @!attribute neuter_name
#   @return [String]
#   Species name which are adjective or participle change depending on the gender of the genus.
#   3 fields provide alternative species spelling. The part_of_speech is designated as a taxon_name_classification.
#   The gender of a genus also designated as a taxon_name_classification.
#
# @!cached_valid_taxon_name_id
#   @return [Integer]
#   Stores a taxon_name_id of a valid taxon_name based on taxon_name_ralationships and taxon_name_classifications.
#
# @!attribute cached_classified_as
#   @return [String]
#   if the name was classified in different group (e.g. a genus placed in wrong family).
#
# @!attribute cached
#   @return [String]
#   Genus-species combination for genus and lower, monomial for higher. The string has NO html.
#
# @!attribute verbatim_name
#   @return [String]
#   a representation of what the combination (fully spelled out) or protonym (monomial)
#   *looked like* in its originating publication
#   The sole purpose of this string is to represent visual differences from what is recorded in the
#   latinized version of the name (Protonym#name, Combination#cached) from what was originally transcribed
#
class TaxonName < ActiveRecord::Base

  has_closure_tree
  has_paper_trail :on => [:update] 

  include Housekeeping
  include Shared::DataAttributes
  include Shared::HasRoles
  include Shared::Taggable
  include Shared::Identifiable
  include Shared::Notable
  include Shared::Depictions
  include Shared::Citable
  include Shared::IsData
  include Shared::Confidence
  include SoftValidation
  include Shared::AlternateValues

  ALTERNATE_VALUES_FOR = [:rank_class].freeze # don't even think about putting this on #name

  EXCEPTED_FORM_TAXON_NAME_CLASSIFICATIONS = [
    'TaxonNameClassification::Iczn::Unavailable::NotLatin',
    'TaxonNameClassification::Iczn::Unavailable::LessThanTwoLetters',
    'TaxonNameClassification::Iczn::Unavailable::NotLatinizedAfter1899',
    'TaxonNameClassification::Iczn::Unavailable::NotLatinizedBefore1900AndNotAccepted',
    'TaxonNameClassification::Iczn::Unavailable::NonBinomial',
    'TaxonNameClassification::Iczn::Available::Invalid::FamilyGroupNameForm'
  ].freeze

  NO_CACHED_MESSAGE = 'PROJECT REQUIRES TAXON NAME CACHE REBUILD'.freeze
  
  SPECIES_EPITHET_RANKS = %w{species subspecies variety subvariety form subform}.freeze
 
  NOT_LATIN = Regexp.new(/[^a-zA-Z|\-]/).freeze # Dash is allowed?

  delegate :nomenclatural_code, to: :rank_class
  delegate :rank_name, to: :rank_class

  # @return [Boolean]
  #   When true, also creates an OTU that is tied to this taxon name
  attr_accessor :also_create_otu

  # @return [Boolean]
  #   When true cached values are not built
  attr_accessor :no_cached

  before_validation :set_type_if_empty

  before_save :set_cached_names
  after_save :create_new_combination_if_absent, unless: 'self.no_cached'
  after_save :set_cached_names_for_dependants_and_self, unless: 'self.no_cached' # !!! do we run set cached names 2 x !?!
  after_save :set_cached_valid_taxon_name_id
  
  before_destroy :check_for_children, prepend: true

  validate :validate_rank_class_class,
    # :check_format_of_name,
    :validate_parent_rank_is_higher,
    :validate_parent_is_set,
    :check_new_rank_class,
    :check_new_parent_class,
    :validate_source_type,
    :validate_one_root_per_project

  validates_presence_of :type, message: 'is not specified'

  # TODO: think of a different name, and test
  has_many :historical_taxon_names, class_name: 'TaxonName', foreign_key: :cached_valid_taxon_name_id 

  belongs_to :valid_taxon_name, class_name: 'TaxonName', foreign_key: :cached_valid_taxon_name_id
  has_one :source_classified_as_relationship, -> {
    where(taxon_name_relationships: {type: 'TaxonNameRelationship::SourceClassifiedAs'} ) 
  }, class_name: 'TaxonNameRelationship::SourceClassifiedAs', foreign_key: :subject_taxon_name_id

  has_one :source_classified_as, through: :source_classified_as_relationship, source: :object_taxon_name 

  has_many :otus, inverse_of: :taxon_name, dependent: :restrict_with_error 
  has_many :related_taxon_name_relationships, class_name: 'TaxonNameRelationship', foreign_key: :object_taxon_name_id, dependent: :restrict_with_error, inverse_of: :object_taxon_name
  has_many :taxon_name_author_roles, class_name: 'TaxonNameAuthor', as: :role_object, dependent: :destroy
  has_many :taxon_name_authors, through: :taxon_name_author_roles, source: :person
  has_many :taxon_name_classifications, dependent: :destroy, foreign_key: :taxon_name_id, inverse_of: :taxon_name
  has_many :taxon_name_relationships, foreign_key: :subject_taxon_name_id, dependent: :restrict_with_error, inverse_of: :subject_taxon_name

  # NOTE: Protonym subclassed methods might not be nicely tracked here, we'll have to see.  Placement is after has_many relationships. (?)
  accepts_nested_attributes_for :related_taxon_name_relationships, allow_destroy: true, reject_if: proc { |attributes| attributes['type'].blank? || attributes['subject_taxon_name_id'].blank? }
  accepts_nested_attributes_for :taxon_name_authors, :taxon_name_author_roles, allow_destroy: true
  accepts_nested_attributes_for :taxon_name_classifications, allow_destroy: true, reject_if: proc { |attributes| attributes['type'].blank?  }

  scope :with_type, -> (type) {where(type: type)} 

  scope :descendants_of, -> (taxon_name) { with_ancestor(taxon_name )}

  scope :ancestors_of, -> (taxon_name) { 
    joins(:descendant_hierarchies)
      .where(taxon_name_hierarchies: {descendant_id: taxon_name.id})
      .where('taxon_name_hierarchies.ancestor_id != ?', taxon_name.id) 
      .order('taxon_name_hierarchies.generations DESC') # root is at index 0
  }

  # LEAVE UNORDERED, if you want order:
  #   .order('taxon_name_hierarchies.generations DESC') 
  scope :self_and_ancestors_of, -> (taxon_name) {
    joins(:descendant_hierarchies)
      .where(taxon_name_hierarchies: {descendant_id: taxon_name.id})
  }

  #  Subtly different, it includes the target taxon, it also doesn't order the result
  #  !! careful, using .pluck on this will give incorrect results, as uniq is applied to strings,
  #  forcing, for example, identical subspecies or subgenera names to be excluded
  # (cost=1537445.24..1537473.50 rows=2826 width=366)
  #  scope :ancestors_and_descendants_of, -> (taxon_name) { 
  #    joins('LEFT OUTER JOIN taxon_name_hierarchies a ON taxon_names.id = a.descendant_id
  #          LEFT JOIN taxon_name_hierarchies b ON taxon_names.id = b.ancestor_id')
  #      .where("(a.ancestor_id = ?) OR (b.descendant_id = ?)", taxon_name.id, taxon_name.id )
  #      .uniq 
  #  }
  #
  # Replaces with: 
  #
  # (cost=2372.84..2375.07 rows=223 width=366)
  #  Subtly different, it includes the target taxon, it also doesn't order the result
  scope :ancestors_and_descendants_of, -> (taxon_name) do
    a = TaxonName.self_and_ancestors_of(taxon_name)
    b = TaxonName.descendants_of(taxon_name)
    TaxonName.from("((#{a.to_sql}) UNION (#{b.to_sql})) as taxon_names")
  end 

  scope :with_rank_class, -> (rank_class_name) { where(rank_class: rank_class_name) }
  scope :with_parent_taxon_name, -> (parent) { where(parent_id: parent) }
  scope :with_base_of_rank_class, -> (rank_class) { where('rank_class LIKE ?', "#{rank_class}%") }
  scope :with_rank_class_including, -> (include_string) { where('rank_class LIKE ?', "%#{include_string}%") }
  scope :project_root, -> (root_id) {where("(taxon_names.rank_class = 'NomenclaturalRank' AND taxon_names.project_id = ?)", root_id)}

  # A specific relationship
  scope :as_subject_with_taxon_name_relationship, -> (taxon_name_relationship) { includes(:taxon_name_relationships).where(taxon_name_relationships: {type: taxon_name_relationship}) }
  scope :as_subject_with_taxon_name_relationship_base, -> (taxon_name_relationship) { includes(:taxon_name_relationships).where('taxon_name_relationships.type LIKE ?', "#{taxon_name_relationship}%").references(:taxon_name_relationships) }
  scope :as_subject_without_taxon_name_relationship_base, -> (taxon_name_relationship) { includes(:taxon_name_relationships).where('(taxon_name_relationships.type NOT LIKE ?) OR (taxon_name_relationships.subject_taxon_name_id IS NULL)', "#{taxon_name_relationship}%").references(:taxon_name_relationships) }
  scope :as_subject_with_taxon_name_relationship_containing, -> (taxon_name_relationship) { includes(:taxon_name_relationships).where('taxon_name_relationships.type LIKE ?', "%#{taxon_name_relationship}%").references(:taxon_name_relationships) }
  scope :as_object_with_taxon_name_relationship, -> (taxon_name_relationship) { includes(:related_taxon_name_relationships).where(taxon_name_relationships: {type: taxon_name_relationship}) }
  scope :as_object_with_taxon_name_relationship_base, -> (taxon_name_relationship) { includes(:related_taxon_name_relationships).where('taxon_name_relationships.type LIKE ?', "#{taxon_name_relationship}%").references(:related_taxon_name_relationships) }
  scope :as_object_with_taxon_name_relationship_containing, -> (taxon_name_relationship) { includes(:related_taxon_name_relationships).where('taxon_name_relationships.type LIKE ?', "%#{taxon_name_relationship}%").references(:related_taxon_name_relationships) }

  # Merge Left Join  (cost=1.27..143262.06 rows=2550 width=366)
  # scope :with_taxon_name_relationship, -> (relationship) {
  #   joins('LEFT OUTER JOIN taxon_name_relationships tnr1 ON taxon_names.id = tnr1.subject_taxon_name_id').
  #   joins('LEFT OUTER JOIN taxon_name_relationships tnr2 ON taxon_names.id = tnr2.object_taxon_name_id').
  #   where('tnr1.type = ? OR tnr2.type = ?', relationship, relationship)
  # }

  #  HashAggregate  (cost=22014.99..22037.11 rows=2212 width=366)
  def self.with_taxon_name_relationship(relationship)
    a = TaxonName.joins(:taxon_name_relationships).where(taxon_name_relationships: {type: relationship})
    b = TaxonName.joins(:related_taxon_name_relationships).where(taxon_name_relationships: {type: relationship})
    TaxonName.from("((#{a.to_sql}) UNION (#{b.to_sql})) as taxon_names")
  end


  # *Any* relationship where there IS a relationship for a subject/object/both
  scope :with_taxon_name_relationships_as_subject, -> { joins(:taxon_name_relationships) }
  scope :with_taxon_name_relationships_as_object, -> { joins(:related_taxon_name_relationships) }

  scope :with_taxon_name_relationships, -> {
    joins('LEFT OUTER JOIN taxon_name_relationships tnr1 ON taxon_names.id = tnr1.subject_taxon_name_id').
    joins('LEFT OUTER JOIN taxon_name_relationships tnr2 ON taxon_names.id = tnr2.object_taxon_name_id').
    where('tnr1.subject_taxon_name_id IS NOT NULL OR tnr2.object_taxon_name_id IS NOT NULL')
  }

  # *Any* relationship where there is NOT a relationship for a subject/object/both
  scope :without_subject_taxon_name_relationships, -> { includes(:taxon_name_relationships).where(taxon_name_relationships: {subject_taxon_name_id: nil}) }
  scope :without_object_taxon_name_relationships, -> { includes(:related_taxon_name_relationships).where(taxon_name_relationships: {object_taxon_name_id: nil}) }

  scope :without_taxon_name_relationships, -> {
    joins('LEFT OUTER JOIN taxon_name_relationships tnr1 ON taxon_names.id = tnr1.subject_taxon_name_id').
    joins('LEFT OUTER JOIN taxon_name_relationships tnr2 ON taxon_names.id = tnr2.object_taxon_name_id').
    where('tnr1.subject_taxon_name_id IS NULL AND tnr2.object_taxon_name_id IS NULL')
  }

  scope :with_parent_id, -> (parent_id) {where(parent_id: parent_id)}

  scope :with_cached_valid_taxon_name_id, -> (cached_valid_taxon_name_id) {where(cached_valid_taxon_name_id: cached_valid_taxon_name_id)}
  scope :with_cached_original_combination, -> (original_combination) { where(cached_original_combination: original_combination) }
  scope :with_cached_html, -> (html) { where(cached_html: html) }

  # @return [Scope] Protonym(s) the **broad sense** synonyms of this name 
  def synonyms 
    TaxonName.with_cached_valid_taxon_name_id(self.id)
  end

  soft_validate(:sv_validate_name, set: :validate_name)
  soft_validate(:sv_missing_fields, set: :missing_fields)
  soft_validate(:sv_parent_is_valid_name, set: :parent_is_valid_name)
  soft_validate(:sv_cached_names, set: :cached_names)
  soft_validate(:sv_not_synonym_of_self, set: :not_synonym_of_self)
  soft_validate(:sv_two_unresolved_alternative_synonyms, set: :two_unresolved_alternative_synonyms)

  # @return [Array]
  #   all TaxonNameRelationships where this taxon is an object or subject.
  def all_taxon_name_relationships
    # !! If self relationships are ever made possible this needs a DISTINCT clause
    TaxonNameRelationship.find_by_sql(
      "SELECT taxon_name_relationships.* 
         FROM taxon_name_relationships 
         WHERE taxon_name_relationships.subject_taxon_name_id = #{self.id} 
       UNION
       SELECT taxon_name_relationships.* 
         FROM taxon_name_relationships 
         WHERE taxon_name_relationships.object_taxon_name_id = #{self.id}")
  end

  # @return [Array of TaxonName]
  #   all taxon_names which have relationships to this taxon as an object or subject.
  def related_taxon_names
       # This was *not* good (3 orders of magnitude slower on big tables):
       # TaxonName.find_by_sql(
       #   "SELECT DISTINCT tn.* FROM taxon_names tn
       #                   LEFT JOIN taxon_name_relationships tnr1 ON tn.id = tnr1.subject_taxon_name_id
       #                   LEFT JOIN taxon_name_relationships tnr2 ON tn.id = tnr2.object_taxon_name_id
       #                   WHERE tnr1.object_taxon_name_id = #{self.id} OR tnr2.subject_taxon_name_id = #{self.id};")
    TaxonName.find_by_sql(
      "SELECT tn.* from taxon_names tn join taxon_name_relationships tnr1 on tn.id = tnr1.subject_taxon_name_id and tnr1.object_taxon_name_id = #{self.id} 
      UNION
      SELECT tn.* from taxon_names tn join taxon_name_relationships tnr2 on tn.id = tnr2.object_taxon_name_id and tnr2.subject_taxon_name_id = #{self.id}"
    )
  end
  
  # @return [String]
  #   rank as human readable shortform, like 'genus' or 'species'
  def rank
    ::RANKS.include?(rank_string) ? rank_name : nil
  end

  # @return [String]
  #   rank (Kindom, Phylum...) as a string, like {NomenclaturalRank::Iczn::SpeciesGroup::Species}
  def rank_string
    read_attribute(:rank_class)
  end

  def rank_class=(value)
    write_attribute(:rank_class, value.to_s)
  end

  # @return [NomenclaturalRank class]
  #   rank as a {NomenclaturalRank} class, like {NomenclaturalRank::Iczn::SpeciesGroup::Species}
  def rank_class
    r = read_attribute(:rank_class)
    Ranks.valid?(r) ? r.safe_constantize : r
  end

  # @return [String, nil]
  #   the baseline means of displaying name authorship, i.e. the author for this taxon, last name only.
  # Important, string format priority is 1) as provided verbatim, 2) as generated from people, and 3) as taken from the source.
  def author_string
    return verbatim_author if !verbatim_author.nil?
    return taxon_name_authors.pluck(&:last_name).to_sentence if taxon_name_authors.any?
    return source.authority_name if !source.nil?
    nil
  end

  # @return [Integer]
  #   a 4 digit integer representing year of publication, like 1974
  def year_integer
    return year_of_publication if !year_of_publication.nil?
    try(:source).try(:year)
  end

  # Used to determine nomenclatural priorities
  # @return [Time]
  #   effective date of publication.
  def nomenclature_date
    return nil if self.id.nil?
     family_before_1961 = TaxonNameRelationship.where_subject_is_taxon_name(self).with_type_string('TaxonNameRelationship::Iczn::PotentiallyValidating::FamilyBefore1961').first

    # family_before_1961 = taxon_name_relationships.with_type_string('TaxonNameRelationship::Iczn::PotentiallyValidating::FamilyBefore1961').first
    if family_before_1961.nil?
      year = self.year_of_publication ? Time.utc(self.year_of_publication, 12, 31) : nil
      self.source ? (self.source.cached_nomenclature_date ? self.source.cached_nomenclature_date.to_time : year) : year
    else
      obj  = family_before_1961.object_taxon_name
      year = obj.year_of_publication ? Time.utc(obj.year_of_publication, 12, 31) : nil
      obj.source ? (self.source.cached_nomenclature_date ? obj.source.cached_nomenclature_date.to_time : year) : year
    end
  end

  # @return [Class, nil]
  #   gender of a genus as class
  def gender_class
    gender_instance.try(:type_class)
  end

  # @return [TaxonNameClassification instance, nil]  
  #    the gender classification of this name, if provided
  def gender_instance
    taxon_name_classifications.with_type_base('TaxonNameClassification::Latinized::Gender').first
  end

  # @return [String]
  #    gender as a string (only applicable to Genera)
  def gender_name
    gender_instance.try(:classification_label).try(:downcase)
  end

  # @return [Class]
  #   part of speech of a species as class.
  def part_of_speech_class
    part_of_speech_instance.try(:type_class)
  end

  def part_of_speech_instance
    taxon_name_classifications.with_type_base('TaxonNameClassification::Latinized::PartOfSpeech').first
  end

  # @return [String]
  #   part of speech of a species as string.
  def part_of_speech_name
    part_of_speech_instance.try(:classification_label).try(:downcase) 
  end

  # @return [Array of String]
  #   the unique string labels derived from TaxonNameClassifications 
  def statuses_from_classifications
    list = taxon_name_classifications_for_statuses
    list.empty? ? [] : list.collect{|c| c.classification_label }.sort
  end

  def taxon_name_classifications_for_statuses
    taxon_name_classifications.with_type_array(ICZN_TAXON_NAME_CLASSIFICATION_NAMES + ICN_TAXON_NAME_CLASSIFICATION_NAMES + ICNB_TAXON_NAME_CLASSIFICATION_NAMES)
  end

  # @return [Array of String]
  #   the unique string labels derived from and TaxonNameRelationships
  def statuses_from_relationships
    list = taxon_name_relationships.with_type_array(STATUS_TAXON_NAME_RELATIONSHIP_NAMES)
    list.empty? ? [] : list.collect{|c| c.subject_status}.sort
  end

  # @return [Array of String]
  #   the unique string labels derived from both TaxonNameClassifications and TaxonNameRelationships
  def combined_statuses
    (statuses_from_classifications + statuses_from_relationships).uniq.sort
  end

  # @return [Array of Protonym]
  #   all of the names this name has been in in combinations
  def combination_list_all
    # list = TaxonNameRelationship.where_subject_is_taxon_name(self).with_type_base('TaxonNameRelationship::Combination')
    taxon_name_relationships.with_type_base('TaxonNameRelationship::Combination').collect{|r| r.object_taxon_name}.uniq
    # return [] if list.empty?
    # list.collect{|r| r.object_taxon_name}.uniq
  end

  # @return [Array of Protonym]
  #   for all names this name has been in combination with, select those names that are of the same rank (!! CONFIRM?)
  def combination_list_self
    # list = 
    # return [] if list.empty?
    combination_list_all.select{|c| c.protonyms_by_rank[c.protonyms_by_rank.keys.last] == self}
  end

  # @return [String]
  #   combination of cached_html and cached_author_year.
  def cached_html_name_and_author_year
    [cached_html, cached_author_year].compact.join(' ')
 
  end
 
 # @return [String] combination of cached and cached_author_year.
 def cached_name_and_author_year
   [cached, cached_author_year].compact.join(' ')
 end

  # @return [TaxonName, nil] an ancestor at the specified rank
 def ancestor_at_rank(rank)
   ancestors.with_rank_class(
     Ranks.lookup(nomenclatural_code, rank)
   ).first
 end

  # @return [Array of TaxonName] ancestors of type 'Protonym'
  def ancestor_protonyms
    Protonym.ancestors_of(self)
   # ancestors.where(type: 'Protonym')
  end

  # @return [Array of TaxonName] descendants of type 'Protonym'
  def descendant_protonyms
    Protonym.descendants_of(self)
  end

  # @return [Boolean]
  #   after all inference on the validity of a name, the result is stored
  #   in cached_valid_taxon_name_id, #is_valid checks that result
  def is_valid?
    id == cached_valid_taxon_name_id
  end

  # @return [Boolean]
  #   true if there is a relationship where then name is asserted to be invalid 
  def relationship_invalid?
    !first_possible_valid_taxon_name_relationship.nil? 
  end

  # @return [Boolean]
  #  true if this name has any classification asserting that it is valid
  def classification_valid?
    taxon_name_classifications.with_type_array(TAXON_NAME_CLASS_NAMES_VALID).any? # !TaxonNameClassification.where_taxon_name(self).with_type_array(TAXON_NAME_CLASS_NAMES_VALID).empty?
  end

  # @return [Boolean]
  #  whether this name has any classification asserting that this the name is NOT valid or that it is unavailable
  def classification_invalid_or_unavailable?
    taxon_name_classifications.with_type_array(TAXON_NAME_CLASS_NAMES_UNAVAILABLE_AND_INVALID).any? # !TaxonNameClassification.where_taxon_name(self).with_type_array(TAXON_NAME_CLASS_NAMES_VALID).empty?
  end

  #  @return [Boolean] 
  #     return true if name is unavailable OR invalid, else false, checks both classifications and relationships
  def unavailable_or_invalid?
    return false if classification_valid?
    classification_invalid_or_unavailable? || relationship_invalid?
  end

  # @return [True|False]
  #   true if this name has a TaxonNameClassification of Fossil
  def fossil?
    # !TaxonNameClassification.where_taxon_name(self).with_type_contains('Fossil').empty? ? true : false
    taxon_name_classifications.with_type_contains('Fossil').any?
  end

  # @return [True|False]
  #   true if this name has a TaxonNameClassification of hybrid 
  def hybrid?
    taxon_name_classifications.where_taxon_name(self).with_type_contains('Hybrid').any?
    #   !TaxonNameClassification.where_taxon_name(self).with_type_contains('Hybrid').empty? ? true : false
  end

  # @return [TaxonName]
  #  a valid taxon_name for an invalid name or self for valid name.
  #  a stub here - See Protonym and Combination
  def get_valid_taxon_name
    nil
  end

  # @return [TaxonNameRelationship]
  #  returns youngest taxon name relationship where self is the subject.
  def first_possible_valid_taxon_name_relationship
    taxon_name_relationships(true).with_type_array(TAXON_NAME_RELATIONSHIP_NAMES_INVALID).youngest_by_citation 
  end

  # @return [TaxonName]
  #    returns the youngest #object_taxon_name from the youngest taxon name relationship.
  def first_possible_valid_taxon_name
    return self if !unavailable_or_invalid?                      # catches all cases where no Classifications or Relationships are provided
    relationship = first_possible_valid_taxon_name_relationship  
    relationship.nil? ? self : relationship.object_taxon_name    # ?! probably the if is caught by unavailable_or_invalid already
   end

  # @return [Array of TaxonName]
  #  returns list of invalid names for a given taxon.
  # TODO: Can't we just use #valid_id now?
  def list_of_invalid_taxon_names
    first_pass = true
    list = {}
    while first_pass || !list.keys.select{|t| list[t] == false}.empty? do
      first_pass = false
      list_of_taxa_to_check = list.empty? ? [self] : list.keys.select{|t| list[t] == false}
      list_of_taxa_to_check.each do |t|
        potentialy_invalid_relationships = t.related_taxon_name_relationships.with_type_array(TAXON_NAME_RELATIONSHIP_NAMES_INVALID).order_by_oldest_source_first
        potentialy_invalid_relationships.find_each do |r|
          if !TaxonNameClassification.where_taxon_name(r.subject_taxon_name).with_type_array(TAXON_NAME_CLASS_NAMES_VALID).empty?
            # do nothing, taxon has a status of valid name
          elsif r == r.subject_taxon_name.first_possible_valid_taxon_name_relationship
            list[r.subject_taxon_name] = false if list[r.subject_taxon_name].nil?
          end

        end
        list[t] = true if list[t] == false
      end
    end
    return [] if list.empty?
    list.sort_by{|t, a| (t.nomenclature_date || Time.now)}.collect{|t, a| t}
  end

  def gbif_status_array
    return nil if self.class.nil?
    return ['combination'] if self.class == 'Combination' 
    s1 = self.taxon_name_classifications.collect{|c| c.class.gbif_status}.compact
    return s1 unless s1.empty?
    s2 = self.taxon_name_relationships.collect{|r| r.class.gbif_status_of_subject}
    s3 = self.related_taxon_name_relationships.collect{|r| r.class.gbif_status_of_object}

    s = s2 + s3
    s.compact!
    return ['valid'] if s.empty?
    s
  end

  # @return [Array of Strings]
  #   names of all genera where the species was placed
  def name_in_gender(gender = nil)
    case gender
      when 'masculine'
        n = self.masculine_name
      when 'feminine'
        n = self.feminine_name
      when 'neuter'
        n = self.neuter_name
      else
        n = nil
    end
    n = n.blank? ? self.name : n
    return n
  end

  #region Set cached fields

  def set_type_if_empty
    self.type = 'Protonym' if self.type.nil? || self.type == 'TaxonName'
  end

  def set_cached_names
    if self.no_cached
      self.cached = NO_CACHED_MESSAGE
      self.cached_author_year = NO_CACHED_MESSAGE
      self.cached_classified_as = NO_CACHED_MESSAGE
      self.cached_html = NO_CACHED_MESSAGE
     #  self.cached_higher_classification = NO_CACHED_MESSAGE
    elsif self.errors.empty?
      set_cached

      # if updated, update also sv_cached_names
      set_cached_html
      set_cached_author_year
      set_cached_classified_as
      set_cached_original_combination
    end
  end

  def create_new_combination_if_absent
    return true unless self.type == 'Protonym'
    if !TaxonName.with_cached_html(self.cached_html).count == 0
      begin
        TaxonName.transaction do
          c = Combination.new
          safe_self_and_ancestors.each do |i|
            case i.rank
              when 'genus'
                c.genus = i
              when 'subgenus'
                c.subgenus = i
              when 'species'
                c.species = i
              when 'subspecies'
                c.subspecies = i
            end
          end
          c.save
        end
      rescue
      end
      false
    end
  end

  def set_cached_valid_taxon_name_id
    true # set in protonym and combination
  end

  def set_cached_names_for_dependants_and_self
    dependants = []
    original_combination_relationships = []
    combination_relationships = []
    
    begin
      TaxonName.transaction do

        if rank_string =~/Species|Genus/
          dependants = Protonym.descendants_of(self).to_a # self.descendant_protonyms 
          original_combination_relationships = TaxonNameRelationship.where_subject_is_taxon_name(self).with_type_contains('OriginalCombination')
          combination_relationships = TaxonNameRelationship.where_subject_is_taxon_name(self).with_type_contains('::Combination')
        end

        dependants.push(self)
        classified_as_relationships = TaxonNameRelationship.where_object_is_taxon_name(self).with_type_contains('SourceClassifiedAs')
        hybrid_relationships = TaxonNameRelationship.where_subject_is_taxon_name(self).with_type_contains('Hybrid')

        unless dependants.empty?
          dependants.each do |i|
            i.update_columns(cached: i.get_full_name,
                             cached_html: i.get_full_name_html)
            if i.rank_string =~ /Species/
              i.update_columns(:cached_secondary_homonym => i.get_genus_species(:current, :self),
                               :cached_secondary_homonym_alternative_spelling => i.get_genus_species(:current, :alternative))
            end
          end
        end

        unless original_combination_relationships.empty?
          related_taxa = original_combination_relationships.collect{|i| i.object_taxon_name}.uniq
          related_taxa.each do |i|
            i.update_cached_original_combinations
          end
        end

        unless combination_relationships.empty?
          related_taxa = combination_relationships.collect{|i| i.object_taxon_name}.uniq
          related_taxa.each do |i|
            i.update_columns(cached: i.get_full_name,
                             cached_html: i.get_full_name_html)
          end
        end

        unless classified_as_relationships.empty?
          related_taxa = classified_as_relationships.collect{|i| i.subject_taxon_name}.uniq
          related_taxa.each do |i|
            i.update_column(:cached_classified_as, i.get_cached_classified_as)
          end
        end

        unless hybrid_relationships.empty?
          related_taxa = classified_as_relationships.collect{|i| i.object_taxon_name}.uniq
          related_taxa.each do |i|
            i.update_columns(cached: i.get_full_name,
                             cached_html: i.get_full_name_html)
          end
        end

      end
      rescue
    end
  end

  def update_cached_original_combinations
    self.update_columns(
      cached_original_combination: self.get_original_combination,
      cached_primary_homonym: self.get_genus_species(:original, :self),
      cached_primary_homonym_alternative_spelling: self.get_genus_species(:original, :alternative))
  end

  # Abstract method 
  def set_cached
    true
  end

  # override in subclasses
  def set_cached_html
    true
  end

  # overwridden in subclasses 
  def set_cached_original_combination
    true
  end

  def set_cached_author_year
    self.cached_author_year = get_author_and_year
  end

  def set_cached_classified_as
    self.cached_classified_as = get_cached_classified_as
  end

  def get_cached_misspelling
    misspelling = TaxonNameRelationship.where_subject_is_taxon_name(self).with_type_contains('::Usage::Misspelling')
    #misspelling = TaxonName.as_subject_with_taxon_name_relationship_containing('::Usage::Misspelling')
    misspelling.empty? ? nil : true
  end

  def is_protonym?
    self.type == 'Protonym'
  end

  def is_combination?
    self.type == 'Combination' 
  end

  # Returns an Array of ancestors
  #   same as self.ancestors, but also works
  #   for new records when parents specified
  def ancestors_through_parents(result = [self], start = self)
    if start.parent.nil?
      return result.reverse
    else
      result << start.parent
      ancestors_through_parents(result, start.parent)
    end
  end

  # @return [Array of TaxonName]
  #   an list of ancestors, Root first
  # Uses parent recursion when record is new and awesome_nested_set_is_not_usable
  def safe_self_and_ancestors
    if self.new_record?
      ancestors_through_parents
    else
    
      self.self_and_ancestors(true).to_a.reverse ## .self_and_ancestors returns empty array!!!!!!!
    end
  end

  # @return [ [rank, prefix, name], ...] for genus and below 
  # @taxon_name.full_name_array # =>  {"genus"=>[nil, "Aus"], "subgenus"=>[nil, "Aus"], "section"=>["sect.", "Aus"], "series"=>["ser.", "Aus"], "species"=>[nil, "aaa"], "subspecies"=>[nil, "bbb"], "variety"=>["var.", "ccc"]\}
  def full_name_array
    gender = nil
    data   = []
    safe_self_and_ancestors.each do |i|
      rank   = i.rank
      gender = i.gender_name if rank == 'genus'
      method = "#{rank.gsub(/\s/, '_')}_name_elements"
      data.push([rank] + send(method, i, gender)) if self.respond_to?(method)
    end
    data
  end

  # @!return [ { rank => [prefix, name] }
  #   Returns a hash of rank => [prefix, name] for genus and below 
  # @taxon_name.full_name_hash # => 
  #      {"genus" => [nil, "Aus"], 
  #       "subgenus" => [nil, "Aus"], 
  #       "section" => ["sect.", "Aus"], 
  #       "series" => ["ser.", "Aus"], 
  #       "species" => [nil, "aaa"], 
  #       "subspecies" => [nil, "bbb"], 
  #       "variety" => ["var.", "ccc"]}
  def full_name_hash

    gender = nil
    data   = {}
    safe_self_and_ancestors.each do |i| # !! You can not use self.self_and_ancestors because (this) record is not saved off.
      rank   = i.rank
      gender = i.gender_name if rank == 'genus'
      method = "#{rank.gsub(/\s/, '_')}_name_elements"
      misspelling = i.cached_misspelling ? ' [sic]' : nil

      if self.respond_to?(method)
        data[rank] = send(method, i, gender)
      else
        data[rank] = i.name
      end
      # data[rank] = send(method, i, gender) if self.respond_to?(method)
    end
    data
  end

  # @return [String]
  #  a monomial if names is above genus, or a full epithet if below. 
  def get_full_name
    return verbatim_name if type != 'Combination' && !GENUS_AND_SPECIES_RANK_NAMES.include?(rank_string) && !verbatim_name.nil?
    return name if type != 'Combination' && !GENUS_AND_SPECIES_RANK_NAMES.include?(rank_string)
    return verbatim_name if !verbatim_name.nil? && type == 'Combination'
    d  = full_name_hash
    elements = []
    elements.push(d['genus'])
    elements.push ['(', d['subgenus'], d['section'], d['subsection'], d['series'], d['subseries'], ')']
    elements.push ['(', d['superspecies'], ')']
    elements.push(d['species'], d['subspecies'], d['variety'], d['subvariety'], d['form'], d['subform'])
    elements = elements.flatten.compact.join(' ').gsub(/\(\s*\)/, '').gsub(/\(\s/, '(').gsub(/\s\)/, ')').squish
    elements.blank? ? nil : elements
    elements
  end

  # @return [String]
  #  a monomial if names is above genus, or a full epithet if below, includes html
  def get_full_name_html
    return verbatim_name if self.type != 'Combination' && !GENUS_AND_SPECIES_RANK_NAMES.include?(self.rank_string) && !self.verbatim_name.nil?
    return name if self.type != 'Combination' && !GENUS_AND_SPECIES_RANK_NAMES.include?(self.rank_string)
    eo = '<i>'
    ec = '</i>'
    return "#{eo}#{verbatim_name}#{ec}".gsub(' f. ', ec + ' f. ' + eo).gsub(' var. ', ec + ' var. ' + eo) if !self.verbatim_name.nil? && self.type == 'Combination'
    return "#{eo}#{name}#{ec}" if self.rank_string == 'NomenclaturalRank::Iczn::GenusGroup::Supergenus' || self.rank_string == 'NomenclaturalRank::Icnb::GenusGroup::Supergenus'
    d = full_name_hash
   
    elements = []
    d['genus'] = [nil, '[' + self.original_genus.cached_html + ']'] if !d['genus'] && self.original_genus
    d['genus'] = [nil, '[GENUS UNKNOWN]'] unless d['genus']

    elements.push("#{eo}#{d['genus'][1]}#{ec}") if d['genus']
    elements.push ['(', %w{subgenus section subsection series subseries superspecies}.collect { |r| d[r] ? [d[r][0], "#{eo}#{d[r][1]}#{ec}"] : nil }, ')']

    SPECIES_EPITHET_RANKS.each do |r|
      elements.push(d[r][0], "#{eo}#{d[r][1]}#{ec}") if d[r]
    end

    html = elements.flatten.compact.join(' ').gsub(/\(\s*\)/, '').gsub(/\(\s/, '(').gsub(/\s\)/, ')').squish.gsub(' [sic]', ec + ' [sic]' + eo).gsub(ec + ' ' + eo, ' ').gsub(eo + ec, '').gsub(eo + ' ', ' ' + eo)
    html = self.fossil? ? '&#8224; ' + html : html

    # Proceps: Why would this be hit here?  It's not type Hybrid
    #
    html = self.hybrid? ? '&#215; ' + html : html
    html
  end

  def genus_name_elements(*args)
    [nil, args[0].name_with_misspelling(args[1])]
  end

  def subgenus_name_elements(*args)
    [nil, args[0].name_with_misspelling(args[1])]
  end

  def section_name_elements(*args)
    ['sect.', args[0].name_with_misspelling(args[1])]
  end

  def subsection_name_elements(*args)
    ['subsect.', args[0].name_with_misspelling(args[1])]
  end

  def series_name_elements(*args)
    ['ser.', args[0].name_with_misspelling(args[1])]
  end

  def subseries_name_elements(*args)
    ['subser.', args[0].name_with_misspelling(args[1])]
  end

  def superspecies_name_elements(*args)
    [nil, args[0].name_with_misspelling(args[1])]
  end

  def species_group_name_elements(*args)
    [nil, args[0].name_with_misspelling(args[1])]
  end

  def species_name_elements(*args)
    [nil, args[0].name_with_misspelling(args[1])]
  end

  def subspecies_name_elements(*args)
    [nil, args[0].name_with_misspelling(args[1])]
  end

  def variety_name_elements(*args)
    ['var.', args[0].name_with_misspelling(args[1])]
  end

  def subvariety_name_elements(*args)
    ['subvar.', args[0].name_with_misspelling(args[1])]
  end

  def form_name_elements(*args)
    ['f.', args[0].name_with_misspelling(args[1])]
  end

  def subform_name_elements(*args)
    ['subf.', args[0].name_with_misspelling(args[1])]
  end

  def name_with_misspelling(gender)
    if self.cached_misspelling
      self.name.to_s + ' [sic]'
    elsif gender.nil? || self.rank_string =~ /Genus/
      self.name.to_s
    else
      self.name_in_gender(gender).to_s
    end
  end

  # TODO: refactor to use us a hash!
  # Returns a String representing the name as originally published
  def get_original_combination
    # strategy is to get the original hash, and swap in values for pertinent relationships
    str = nil

    if GENUS_AND_SPECIES_RANK_NAMES.include?(self.rank_string) && is_protonym?
      relationships = self.original_combination_relationships(true) # force a reload of the relationships

      return nil if relationships.count == 0

      # This can be greatly simplified by swapping in names to the hash method

      relationships = relationships.sort_by{|r| r.type_class.order_index }
      genus         = ''
      subgenus      = ''
      superspecies  = ''
      species       = ''
      gender        = nil

      relationships.each do |i|
        if i.object_taxon_name_id == i.subject_taxon_name_id && !i.object_taxon_name.verbatim_name.blank?
          case i.type # subject_status
            when /OriginalGenus/ #'original genus'
              genus  = '<i>' + i.subject_taxon_name.verbatim_name + '</i> '
              gender = i.subject_taxon_name.gender_name
            when /OriginalSubgenus/ # 'original subgenus'
              subgenus += '<i>' + i.subject_taxon_name.verbatim_name + '</i> '
            when /OriginalSpecies/ #  'original species'
              species += '<i>' + i.subject_taxon_name.verbatim_name + '</i> '
            when /OriginalSubSpecies/ # 'original subspecies'
              species += '<i>' + i.subject_taxon_name.verbatim_name + '</i> '
            when /OriginalVariety/ #  'original variety'
              species += 'var. <i>' + i.subject_taxon_name.verbatim_name + '</i> '
            when /OriginalSubvariety/ # 'original subvariety'
              species += 'subvar. <i>' + i.subject_taxon_name.verbatim_name + '</i> '
            when /OriginalForm/ # 'original form'
              species += 'f. <i>' + i.subject_taxon_name.verbatim_name + '</i> '
            when /OriginalSubform/ #  'original subform'
              species += 'subf. <i>' + i.subject_taxon_name.verbatim_name + '</i> '
          end
        else
          case i.type # subject_status
            when /OriginalGenus/ #'original genus'
              genus  = '<i>' + i.subject_taxon_name.name_with_misspelling(nil) + '</i> '
              gender = i.subject_taxon_name.gender_name
            when /OriginalSubgenus/ # 'original subgenus'
              subgenus += '<i>' + i.subject_taxon_name.name_with_misspelling(nil) + '</i> '
  #          when /OriginalSection/ # 'original section'
  #            subgenus += 'sect. <i>' + i.subject_taxon_name.name_with_misspelling(nil) + '</i> '
  #          when /OriginalSubsection/ #'original subsection'
  #            subgenus += 'subsect. <i>' + i.subject_taxon_name.name_with_misspelling(nil) + '</i> '
  #          when /OriginalSeries/ # 'original series'
  #            subgenus += 'ser. <i>' + i.subject_taxon_name.name_with_misspelling(nil) + '</i> '
  #          when /OriginalSubseries/ #  'original subseries'
  #            subgenus += 'subser. <i>' + i.subject_taxon_name.name_with_misspelling(nil) + '</i> '
            when /OriginalSpecies/ #  'original species'
              species += '<i>' + i.subject_taxon_name.name_with_misspelling(gender) + '</i> '
            when /OriginalSubSpecies/ # 'original subspecies'
              species += '<i>' + i.subject_taxon_name.name_with_misspelling(gender) + '</i> '
            when /OriginalVariety/ #  'original variety'
              species += 'var. <i>' + i.subject_taxon_name.name_with_misspelling(gender) + '</i> '
            when /OriginalSubvariety/ # 'original subvariety'
              species += 'subvar. <i>' + i.subject_taxon_name.name_with_misspelling(gender) + '</i> '
            when /OriginalForm/ # 'original form'
              species += 'f. <i>' + i.subject_taxon_name.name_with_misspelling(gender) + '</i> '
            when /OriginalSubform/ #  'original subform'
              species += 'subf. <i>' + i.subject_taxon_name.name_with_misspelling(gender) + '</i> '
          end
        end
      end

      original_name = self.verbatim_name.nil? ? self.name_with_misspelling(nil) : self.verbatim_name
      if !relationships.empty? && relationships.collect{|i| i.subject_taxon_name_id}.last != self.id
        if self.rank_string =~ /Genus/
          if genus.blank?
            genus += '<i>' + original_name + '</i> '
          else
            subgenus += '<i>' + original_name + '</i> '
          end
        elsif self.rank_string =~ /Species/
          species += '<i>' + original_name + '</i> '
          genus   = '<i>' + self.ancestor_at_rank('genus').name_with_misspelling(nil) + '</i> ' if genus.empty? && !self.ancestor_at_rank('genus').nil?
        end
      end

      subgenus    = '(' + subgenus.squish + ') ' unless subgenus.empty?
      str = (genus + subgenus + superspecies + species).gsub(' [sic]', '</i> [sic]<i>').gsub('</i> <i>', ' ').gsub('<i></i>', '').gsub('<i> ', ' <i>').squish
      str.blank? ? nil : str
    end
  end

  # TODO: @proceps is this used for all subclasses, or just Protonym?
  def get_genus_species(genus_option, self_option)
    return nil if rank_class.nil?
    genus = nil
    name1 = nil

    if genus_option == :original
      genus = self.original_genus
    elsif genus_option == :current
      genus = self.ancestor_at_rank('genus')
    else
      return false
    end
    genus = genus.name unless genus.blank?

    return nil if self.rank_string =~ /Species/ && genus.blank?
    if self_option == :self
      name1 = self.name
    elsif self_option == :alternative
      name1 = name_with_alternative_spelling
    end
    
    return nil if genus.nil? && name1.nil?
    (genus.to_s + ' ' + name1.to_s).squish
  end

  # return [Boolean] whether there is missaplication relationship
  def name_is_missapplied?
    TaxonNameRelationship.where_subject_is_taxon_name(self).
      with_type_string('TaxonNameRelationship::Iczn::Invalidating::Usage::Misapplication').empty?
  end

  # return [String]
  #   the author and year of the name, adds parenthesis where asserted
  def get_author_and_year
    # see protonym and combination
    true
  end

  def icn_author_and_year
    ay = nil

    basionym = TaxonNameRelationship.where_object_is_taxon_name(self).
      with_type_string('TaxonNameRelationship::Icn::Unaccepting::Usage::Basionym')
    b_sub = basionym.empty? ? nil : basionym.first.subject_taxon_name

    misapplication = TaxonNameRelationship.where_subject_is_taxon_name(self).
      with_type_string('TaxonNameRelationship::Icn::Unaccepting::Usage::Misapplication')
    m_obj = misapplication.empty? ? nil : misapplication.first.object_taxon_name

    t  = [self.author_string]
    t  += ['(' + self.year_integer.to_s + ')'] unless self.year_integer.nil?
    ay = t.compact.join(' ')

    unless basionym.empty? || b_sub.author_string.blank?
      ay = '(' + b_sub.author_string + ') ' + ay
    end

    unless misapplication.empty? || m_obj.author_string.blank?
      ay += ' nec ' + [m_obj.author_string]
      t  += ['(' + m_obj.year_integer.to_s + ')'] unless m_obj.year_integer.nil?
      ay = t.compact.join(' ')
    end
    
    ay.blank? ? nil : ay
  end

  def iczn_author_and_year
    ay = nil
    p = nil

    misapplication = TaxonNameRelationship.where_subject_is_taxon_name(self).with_type_string('TaxonNameRelationship::Iczn::Invalidating::Usage::Misapplication')

    if self.type == 'Combination'
      c = self.protonyms_by_rank
      return nil if c.empty?
      taxon = c[c.keys.last]
    else
      taxon = self
    end

    a = [taxon.try(:author_string)]
    y = [taxon.try(:year_integer)]

    if a[0] =~ /^\(.+\)$/ # (Author)
      a[0] = a[0][1..-2] ## remove parentheses in the author string
      p = true
    else
      p = false
    end

    ay = (a + y).compact.join(', ')

    obj = misapplication.empty? ? nil : misapplication.first.object_taxon_name

    unless misapplication.empty? || obj.author_string.blank?
      ay += ' nec ' + ([obj.author_string] + [obj.year_integer]).compact.join(', ')
    end

    if SPECIES_RANK_NAMES_ICZN.include?(taxon.rank_string)
      if p
        ay = '(' + ay + ')' unless ay.empty?
      else
        og = taxon.original_genus
        if self.type == 'Combination'
          cg = self.genus
        else
          cg = self.ancestor_at_rank('genus')
        end
        unless og.nil? || cg.nil?
          ay = '(' + ay + ')' unless ay.empty? if og.name != cg.name
        end
        #((self.original_genus.name != self.ancestor_at_rank('genus').name) && !self.original_genus.name.to_s.empty?)
      end
    end

    ay.blank? ? nil : ay
  end

  def get_cached_classified_as
    return nil unless   is_protonym? || is_combination? 
    r = self.source_classified_as(true)
    unless r.blank?
      return " (as #{r.name})"
    end
    nil
  end

  # A proxy for a scope
  # @return [Array of TaxonName] 
  #   ordered by rank
  def self.sort_by_rank(taxon_names)
    taxon_names.sort!{|a,b| RANKS.index(a.rank_string) <=> RANKS.index(b.rank_string)} 
  end

  #endregion

  def parent_is_set?
    !self.parent_id.nil? || (self.parent && self.parent.persisted?)
  end

  def next_sibling
    if siblings.any?
      siblings = self_and_siblings.order(:cached).pluck(:id)
      s = siblings.index(id)
      TaxonName.find(siblings[ s + 1]) if s < siblings.length - 1
    else
      nil
    end
  end

  def previous_sibling
    if siblings.any?
      siblings = self_and_siblings.order(:cached).pluck(:id)
      s = siblings.index(id)
      TaxonName.find(siblings[ s - 1]) if s != 0 
    else
      nil 
    end
  end

  protected

  def check_for_children
    if leaf? 
      true
    else
      errors.add(:base, "has attached names, delete these first")
      false 
    end
  end

  #region Validation

  def validate_parent_is_set
    if !(self.rank_class == NomenclaturalRank) && !(self.type == 'Combination')
      errors.add(:parent_id, 'is not selected') if !parent_is_set?  # self.parent_id.blank? && (self.parent.blank? || !self.parent.persisted?)
    end
  end

  def validate_parent_rank_is_higher
    if self.parent && !self.rank_class.blank? && self.rank_string != 'NomenclaturalRank'
      if RANKS.index(self.rank_string) <= RANKS.index(self.parent.rank_string)
        errors.add(:parent_id, "The parent rank (#{self.parent.rank_class.rank_name}) is not higher than #{rank_name}")
      end

      if (self.rank_class != self.rank_class_was) && # TODO: @proceps this catches nothing, as self.rank_class_was is never defined!
        self.children &&
        !self.children.empty? &&
        RANKS.index(self.rank_string) >= self.children.collect { |r| RANKS.index(r.rank_string) }.max
        errors.add(:rank_class, "The taxon rank (#{rank_name}) is not higher than child ranks")
      end
    end
  end

  def validate_one_root_per_project
    if new_record? || project_id_changed?
      if !parent_is_set? && TaxonName.where(parent_id: nil, project_id: self.project_id).count > 0
        errors.add(:parent_id, 'is empty, only one root is allowed per project') 
      end
    end 
  end

  # TODO: move to Protonym
  def check_new_parent_class
    if is_protonym? && self.parent_id != self.parent_id_was && !self.parent_id_was.nil? && nomenclatural_code == :iczn
      if old_parent = TaxonName.find_by(id: self.parent_id_was)
        if (rank_name == 'subgenus' || rank_name == 'subspecies') && old_parent.name == self.name
          errors.add(:parent_id, "The nominotypical #{rank_name} #{name} could not be moved out of the nominal #{old_parent.rank_name}")
        end
      end
    end
  end

  # See subclasses
  def validate_rank_class_class
    true
  end

  def check_new_rank_class
    # rank_class_was is a AR macro 

    if (self.rank_class != self.rank_class_was) && !self.rank_class_was.nil?

      if self.rank_class_was == 'NomenclaturalRank' 
        errors.add(:rank_class, "Root can not have a new rank")
        return
      end

      old_rank_group = self.rank_class_was.safe_constantize.parent
      if self.rank_class.parent != old_rank_group
        errors.add(:rank_class, "A new taxon rank (#{rank_name}) should be in the #{old_rank_group.rank_name}")
      end
    end
  end

  def validate_source_type
    errors.add(:base, 'Source must be a Bibtex') if self.source && self.source.type != 'Source::Bibtex'
  end

  #TODO: validate that all the ranks in the table could be linked to ranks in classes (if those had changed)

  #endregion

  #region Soft validation

  def sv_validate_name
    correct_name_format = false

    if self.rank_class
      # TODO: name these Regexp somewhere
      if (self.name =~ /^[a-zA-Z]*$/) || # !! should reference NOT_LATIN 
          (nomenclatural_code == :iczn && self.name =~ /^[a-zA-Z]-[a-zA-Z]*$/) ||
          (nomenclatural_code == :icnb && self.name =~ /^[a-zA-Z]-[a-zA-Z]*$/) ||
          (nomenclatural_code == :icn && self.name =~  /^[a-zA-Z]*-[a-zA-Z]*$/) ||
          (nomenclatural_code == :icn && self.name =~ /^[a-zA-Z]*\s×\s[a-zA-Z]*$/) ||
          (nomenclatural_code == :icn && self.name =~ /^×\s[a-zA-Z]*$/)
        correct_name_format = true
      end

      unless correct_name_format
        invalid_statuses = TAXON_NAME_CLASS_NAMES_UNAVAILABLE_AND_INVALID
        invalid_statuses = invalid_statuses & taxon_name_classifications.pluck(&:type_class) # self.taxon_name_classifications.collect { |c| c.type_class.to_s }
        misspellings     = TaxonNameRelationship.collect_to_s(
          TaxonNameRelationship::Iczn::Invalidating::Usage::IncorrectOriginalSpelling,
          TaxonNameRelationship::Iczn::Invalidating::Usage::Misspelling,
          TaxonNameRelationship::Icn::Unaccepting::Usage::Misspelling)

        misspellings     = misspellings & taxon_name_relationships.pluck(&:type_class) # self.taxon_name_relationships.collect { |c| c.type_class.to_s }
        if invalid_statuses.empty? && misspellings.empty?
          soft_validations.add(:name, 'Name should not have spaces or special characters, unless it has a status of misspelling')
        end
      end
    end

  end

  def sv_missing_fields
    soft_validations.add(:base, 'Source is missing') if self.source.nil?
    soft_validations.add(:verbatim_author, 'Author is missing',
                         fix: :sv_fix_missing_author,
                         success_message: 'Author was updated') if self.author_string.nil?
    soft_validations.add(:year_of_publication, 'Year is missing',
                         fix: :sv_fix_missing_year,
                         success_message: 'Year was updated') if self.year_integer.nil?
  end

  def sv_fix_missing_author
    if self.source
      unless self.source.author.blank?
        self.verbatim_author = self.source.authority_name
        begin
          TaxonName.transaction do
            self.save
            return true
          end
        rescue
          return false
        end
      end
    end
    false
  end

  def sv_fix_missing_year
    if self.source
      if self.source.year
        self.year_of_publication = self.source.year
        begin
          TaxonName.transaction do
            self.save
            return true
          end
        rescue
          return false
        end
      end
    end
    false
  end

  # TODO: Protonym check only?  Why can't we reference #cached_valid_taxon_name_id?
  def sv_parent_is_valid_name
    return if parent.nil?
    if parent.unavailable_or_invalid?
      # parent of a taxon is unavailable or invalid
      soft_validations.add(:parent_id, 'Parent should be a valid taxon',
                           fix:             :sv_fix_parent_is_valid_name,
                           success_message: 'Parent was updated')
    else # TODO: This seems like a different validation, split with above?
      classifications      = self.taxon_name_classifications(true)
      classification_names = classifications.map { |i| i.type_name }
      compare              = TAXON_NAME_CLASS_NAMES_UNAVAILABLE_AND_INVALID & classification_names
      unless compare.empty?
        
        unless Protonym.with_parent_taxon_name(self).without_taxon_name_classification_array(TAXON_NAME_CLASS_NAMES_UNAVAILABLE_AND_INVALID).empty?

          compare.each do |i|
            # taxon is unavailable or invalid, but has valid children
            soft_validations.add(:base, "Taxon has a status ('#{i.demodulize.underscore.humanize.downcase}') conflicting with presence of subordinate taxa")
          end
        end
      end
    end
  end

  def sv_fix_parent_is_valid_name
    if self.parent.unavailable_or_invalid?
      new_parent = self.parent.get_valid_taxon_name
      if self.parent != new_parent
        self.parent = new_parent
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


  def sv_fix_cached_names
    begin
      TaxonName.transaction do
        self.save
        return true
      end
    rescue
    end
    false
  end

  # TODO: does this make sense now, with #valid_taxon_name_id in place?
  def sv_not_synonym_of_self
    if list_of_invalid_taxon_names.include?(self)
      soft_validations.add(:base, "Taxon has two conflicting relationships (invalidating and validating). To resolve a conflict, add a status 'valid' to a valid taxon.")
    end
  end

  def sv_two_unresolved_alternative_synonyms
    r = taxon_name_relationships.includes(:source).order_by_oldest_source_first.with_type_array(TAXON_NAME_RELATIONSHIP_NAMES_INVALID)
    if r.to_a.count > 1
      if r.first.nomenclature_date.to_date == r.second.nomenclature_date.to_date
        soft_validations.add(:base, "Taxon has two alternative invalidating relationships with identical dates. To resolve ambiguity, add original sources to the relationships with different priority dates.")
      end
    end
  end

  def sv_cached_names
    true # see validation in subclasses
  end

  def sv_validate_parent_rank
    true # see validation in Protonym.rb
  end

  def sv_missing_relationships
    true # see validation in Protonym.rb
  end

  def sv_missing_classifications
    true # see validation in Protonym.rb
  end

  def sv_species_gender_agreement
    true # see validation in Protonym.rb
  end

  def sv_primary_types
    true # see validation in Protonym.rb
  end

  def sv_validate_coordinated_names
    true # see validation in Protonym.rb
  end

  def sv_type_placement
    true # see validation in Protonym.rb
  end

  def sv_single_sub_taxon
    true # see validation in Protonym.rb
  end

  def sv_parent_priority
    true # see validation in Protonym.rb
  end

  def sv_homotypic_synonyms
    true # see validation in Protonym.rb
  end

  def sv_potential_homonyms
    true # see validation in Protonym.rb
  end

  def sv_combination_duplicates
    true # see validation in Combination.rb
  end

  def sv_hybrid_name_relationships
    true # see validation in Hybrid.rb
  end

  #endregion

end


