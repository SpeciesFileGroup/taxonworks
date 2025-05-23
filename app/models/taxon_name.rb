# A taxon name (nomenclature only). See also NOMEN (https://github.com/SpeciesFileGroup/nomen).
#
# @!attribute name
#   @return [String, nil]
#   the fully latinized string (monominal) of a code governed taxonomic biological name
#   not applicable for Combinations, they are derived from their pieces
#
# @!attribute parent_id
#   @return [Integer]
#   The id of the parent taxon. The parent child relationship is exclusively organizational. All statuses and relationships
#   of a taxon name must be explicitly defined via taxon name relationships or classifications. The parent of a taxon name
#   can be thought of as  "the place where you'd find this name in a hierarchy if you knew literally *nothing* else about that name."
#   In practice read each monominal in the name (protonym or combination) from right to left, the parent is the parent of the last monominal read.
#   There are 3 simple rules for determining the parent of a Protonym or Combination:
#     1) the parent must always be at least one rank higher than the target names rank
#     2) the parent of a synonym (any sense) is the parent of the synonym's valid name
#     3) the parent of a combination is the parent of the highest ranked monominal in the epithet (almost always the parent of the genus)
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
#   @param rank_class [String]
#   @return [Class]
#     The NOMEN based rank as a class.  Reflects the current relationship between a name and its synonymy.
#     !! Combinations are "rankless".
#     !! Rank class may be automatically changed when synonymy is applied.  For example if a tribe is
#     synonymized with a subfamily the rank Tribe is updated to subfamily.
#
# @!attribute type
#   @return [String]
#   The subclass of this taxon name, e.g. Protonym or Combination
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
# @!attribute project_id
#   @return [Integer]
#   the project ID
#
# @!attribute verbatim_name
#   @return [String]
#   a representation of what the Combination (fully spelled out) or Protonym (monominal)
#   *looked like* in its originating publication.
#   The sole purpose of this string is to represent visual differences from what is recorded in the
#   latinized version of the name (Protonym#name, Combination#cached) from what was originally transcribed.
#   This string should NOT include the author year (see verbatim_author and year_of_publication for those data).
#
#   If at all possible this field SHOULD NOT be used, it has very little downstream inference use.
#
#   If a subgenus it should ____TODO____ (not?) contain parens.
#
# @!attribute etymology
#   @return [String]
#   the derivation and history of the name in written form
#
# @!attribute cached
#   @return [String]
#   Genus-species combination for genus and lower, monominal for higher. The string has NO html, and no author/year.
#
# @!attribute cached_html
#   @return [String]
#   As in `cached` but with <i></i> tags.
#
# @attribute cached_author
#   @return [String, nil]
#      author string *without* parentheses
#
# @attribute cached_author_year
#   @return [String, nil]
#      author and year string with parentheses where necessary, i.e. with context of present placement for ICZN
#
# @!attribute cached_original_combination
#   @return [String]
#     name as formed in original combination, no author/year, without HTML
#
# @!attribute cached_original_combination_html
#   @return [String]
#    as cached_original_combination but with HTML
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
# @!attribute cached_classified_as
#   @return [String]
#   if the name was classified in different group (e.g. a genus placed in wrong family).
#
# @!cached_valid_taxon_name_id
#   @return [Integer]
#   Stores a taxon_name_id of a 'valid' taxon_name based on taxon_name_relationships. Identifies a claster of taxon_names which should be shown on the same Browse Nomenclature page.
#
# @!cached_is_valid
#   @return [Boolean]
#   Stores if the status of the name is valid based on both taxon_name_relationships and taxon_name_classifications.
#
# @!cached_gender
#   @return [String, nil]
#     applicable to genus group names only!!!
#     one of 'masculine', 'feminine', neuter'
#
# @!cached_is_available
#   @return [Boolean]
#     true - by default
#     false - calculated from TaxonNameRelationships and TaxonNameClassifications
# Tracks, for computation purposes, that status of assertions of availability.
# !! Since Combinations do not recieve TaxonNameRelationship or Classifications
# they are defaulted to false.
#
# rubocop:disable Metrics/ClassLength
#
# TODO: Refactor into
#   * methods that set new state (new values
#     * verbosely touches database
#   * methods that set fixed state (cached, exports)
#     * once state is loaded, it is never reloaded or hit again
#       * sensu TaxonomyObjects
#   * methods that get/check state
#     * sparesly touches database
#
# In general there is too much interplay between the our current variables, they should not (probably) cross boundaries.
#
class TaxonName < ApplicationRecord

  # @return class
  #   this method calls Module#module_parent
  # TODO: This method can be placed elsewhere inside this class (or even removed if not used)
  #       when https://github.com/ClosureTree/closure_tree/issues/346 is fixed.
  # The issue is closed
  # def self.parent
  #   self.module_parent
  # end

  # Must be before various of these includes, in particular MatrixHooks
  has_closure_tree

  include Housekeeping
  include Shared::DataAttributes
  include Shared::Tags
  include Shared::Identifiers
  include Shared::Notes
  include Shared::Depictions
  include Shared::Citations
  include Shared::Confidences
  include Shared::AlternateValues
  include Shared::HasPapertrail
  include Shared::Labels
  include SoftValidation
  include Shared::QueryBatchUpdate
  include TaxonName::OtuSyncronization
  include TaxonName::Hierarchy
  include TaxonName::TextTree

  include Shared::MatrixHooks::Member
  include Shared::MatrixHooks::Dynamic

  include TaxonName::MatrixHooks
  include Shared::DwcOccurrenceHooks
  include Shared::IsData

  # Allows users to provide arbitrary annotations that "over-ride" rank string
  ALTERNATE_VALUES_FOR = [:rank_class].freeze # !! Don't even think about putting this on `name`

  COMBINATION_ELEMENTS = [:genus, :subgenus, :species, :subspecies, :variety, :subvariety, :form, :subform].freeze

  SPECIES_EPITHET_RANKS = %w{species subspecies variety subvariety form subform}.freeze

  NOT_LATIN = Regexp.new(/[^a-zA-Z|\-]/).freeze # Dash is allowed?

  NO_CACHED_MESSAGE = 'REBUILD PROJECT TAXON NAME CACHE'.freeze

  ROOT_NAME = 'Root'

  NOMEN_VALID = {
    icn: 'http://purl.obolibrary.org/obo/NOMEN_0000383',
    icnp: 'http://purl.obolibrary.org/obo/NOMEN_0000081',
    icvcn: 'http://purl.obolibrary.org/obo/NOMEN_0000125',
    iczn: 'http://purl.obolibrary.org/obo/NOMEN_0000224'
  }.freeze

  # See related concept in concerns/shared/taxonomy, this may belong there.
  #
  # @return [Hash]
  attr_reader :taxonomy

  # @return array of all taxon_name_relationships (name is subject), memoized
  # NOT USED
  # attr_accessor :relationships

  def reload(*)
    super.tap do
      @related_relationships = nil
      @taxonomy = nil
      # @relationships = nil
    end
  end

  # @return Array
  #    all taxon_name_relationships (name is object), memoized
  # !! Memoized attributes are not reset when related objects reload them.
  # !! For example if species = subject_taxon_name. of a = TaxonNameRelationship
  # !!  then a.subject_taxon_name.reload is not the same as species.reload
  attr_accessor :related_relationships

  # @return array of all taxon_name_classifications, memoizable
  attr_accessor :classifications

  # @return [Boolean]
  #   When true, also creates an OTU that is tied to this taxon name
  attr_accessor :also_create_otu

  # @return [Boolean]
  #   When true cached values are not built
  attr_accessor :no_cached

  delegate :nomenclatural_code, to: :rank_class, allow_nil: true
  delegate :rank_name, to: :rank_class, allow_nil: true

  # TODO: this was not implemented and tested properly
  # I think the intent is *before* save, i.e. the name will change
  # to a new cached value, so let's record the old one
  #  after_save :create_new_combination_if_absent

  after_create :create_otu, if: :also_create_otu
  before_destroy :check_for_children, prepend: true

  # With this @taxonomy can more or less replace full_name_hash
  #  after_save :reset_taxonomy
  #  def reset_taxonomy
  #    @taxonomy = nil
  #  end

  # Rails 7 experiments have after_commit creating a whack-a-mole situation
  # (though leave after_commit on TaxonNameRelationship)
  after_commit :set_cached, unless: Proc.new {|n| n.no_cached || errors.any? }
  after_commit :set_cached_warnings, if: Proc.new {|n| n.no_cached } # Should definitely be after commit

  validate :validate_rank_class_class
  validate :check_new_rank_class
  validate :check_new_parent_class
  validate :validate_source_type

  validate :validate_parent_from_the_same_project, unless: Proc.new {|n| n.name == ROOT_NAME }

  # Root validations
  validate :validate_root_name_is_root, if: Proc.new {|n| n.name == ROOT_NAME }
  validates_presence_of :parent, unless: Proc.new {|m| self.name == ROOT_NAME}
  validates_uniqueness_of :name, scope: [:project_id], if: Proc.new {|n| n.name == ROOT_NAME}

  # TODO: remove, this is handled natively, and in DB
  validates_presence_of :type, message: 'is not specified'

  validates :year_of_publication, date_year: {min_year: 1000, max_year: Time.now.year + 5}, allow_nil: true

  # TODO: move some of these down to Protonym when they don't apply to Combination

  belongs_to :valid_taxon_name, class_name: 'TaxonName', foreign_key: :cached_valid_taxon_name_id

  has_one :source_classified_as_relationship, -> {
    where(taxon_name_relationships: {type: 'TaxonNameRelationship::SourceClassifiedAs'})
  }, class_name: 'TaxonNameRelationship::SourceClassifiedAs', foreign_key: :subject_taxon_name_id

  has_one :family_group_name_form_relationship, -> {
    where(taxon_name_relationships: {type: 'TaxonNameRelationship::Iczn::Invalidating::Usage::FamilyGroupNameForm'})
  }, class_name: 'TaxonNameRelationship::Iczn::Invalidating::Usage::FamilyGroupNameForm', foreign_key: :subject_taxon_name_id, inverse_of: :subject_taxon_name

  has_one :source_classified_as, through: :source_classified_as_relationship, source: :object_taxon_name

  # TODO: think of a different name, and test
  has_many :historical_taxon_names, class_name: 'TaxonName', foreign_key: :cached_valid_taxon_name_id

  has_many :observation_matrix_row_items, as: :observation_object, inverse_of: :observation_object, class_name: 'ObservationMatrixRowItem::Dynamic::TaxonName', dependent: :destroy # was delete_all
  has_many :observation_matrices, through: :observation_matrix_row_items

  has_many :otus, inverse_of: :taxon_name, dependent: :restrict_with_error
  has_many :taxon_determinations, through: :otus

  has_many :collection_objects, through: :taxon_determinations, source: :taxon_determination_object, source_type: 'CollectionObject'
  has_many :field_occurrences, through: :taxon_determinations, source: :taxon_determination_object, source_type: 'FieldOccurrence'

  has_many :taxon_name_author_roles, class_name: 'TaxonNameAuthor', as: :role_object, dependent: :destroy, inverse_of: :role_object
  has_many :taxon_name_authors, -> { order('roles.position ASC') }, through: :taxon_name_author_roles, source: :person

  # TODO: Combinations shouldn't have classifications or relationships?  Move to Protonym?
  has_many :taxon_name_classifications, dependent: :destroy, inverse_of: :taxon_name
  has_many :taxon_name_relationships, foreign_key: :subject_taxon_name_id, dependent: :restrict_with_error, inverse_of: :subject_taxon_name
  has_many :related_taxon_name_relationships, class_name: 'TaxonNameRelationship', foreign_key: :object_taxon_name_id, dependent: :restrict_with_error, inverse_of: :object_taxon_name

  # NOTE: Protonym subclassed methods might not be nicely tracked here, we'll have to see.  Placement is after has_many relationships. (?)
  accepts_nested_attributes_for :related_taxon_name_relationships, allow_destroy: true, reject_if: proc { |attributes| attributes['type'].blank? || attributes['subject_taxon_name_id'].blank? }
  accepts_nested_attributes_for :family_group_name_form_relationship, allow_destroy: true, reject_if: proc { |attributes| attributes['object_taxon_name_id'].blank? }
  accepts_nested_attributes_for :taxon_name_authors, :taxon_name_author_roles, allow_destroy: true
  accepts_nested_attributes_for :taxon_name_classifications, allow_destroy: true, reject_if: proc { |attributes| attributes['type'].blank?  }

  # TODO: deprecate for cached_is_available
  has_many :classified_as_unavailable_or_invalid, -> { where(type: TAXON_NAME_CLASS_NAMES_UNAVAILABLE_AND_INVALID) }, class_name: 'TaxonNameClassification'

  # Combinations are rankless, but we need this scope here for generic returns
  # In small batches ordering in memory is likely more efficient.
  scope :order_by_rank, -> (code) {order(Arel.sql("position(taxon_names.rank_class in '#{code}')"))}

  scope :with_same_cached_valid_id, -> { where(arel_table[:id].eq(arel_table[:cached_valid_taxon_name_id])) }
  scope :with_different_cached_valid_id, -> { where(arel_table[:id].not_eq(arel_table[:cached_valid_taxon_name_id])) } # This doesn't catch all invalid names.  Those with classifications only are missed !$#!@#

  scope :that_is_valid, -> {where(cached_is_valid: true) }
  scope :that_is_invalid, -> {where(cached_is_valid: false) }

  # @params names Array of Protonym, Hybrid
  #   orders them from Root to tip.
  def self.rank_order(names)
    # There is an edge-case where Combination is converting to Protonym in which there is no rank_class.
    names.sort_by{|a| RANKS.index(a.rank_class.to_s) || 999}
  end

  def self.calculated_invalid
    a = TaxonName.with_different_cached_valid_id # that_is_invalid
    b = TaxonName.joins(:taxon_name_classifications).where(taxon_name_classifications: {type: TAXON_NAME_CLASS_NAMES_UNAVAILABLE_AND_INVALID })
    TaxonName.from("((#{a.to_sql}) UNION (#{b.to_sql})) as taxon_names")
  end

  def self.calculated_valid
    # Alt format: TaxonName.that_is_valid.left_joins(:classified_as_unavailable_or_invalid).merge(TaxonNameClassification.where(id: nil))
    TaxonName
      .with_same_cached_valid_id
      .where.not(
        id: TaxonNameClassification.select(:taxon_name_id).where(type: TAXON_NAME_CLASS_NAMES_UNAVAILABLE_AND_INVALID)
      )
  end

  scope :with_type, -> (type) {where(type:)}
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

  # Includes taxon_name, doesn't order result
  scope :ancestors_and_descendants_of, -> (taxon_name) do
    scoping do
      a = TaxonName.self_and_ancestors_of(taxon_name)
      b = TaxonName.descendants_of(taxon_name)
      TaxonName.from("((#{a.to_sql}) UNION (#{b.to_sql})) as taxon_names")
    end
  end

  # TODO: remove
  scope :with_rank_class, -> (rank_class_name) { where(rank_class: rank_class_name) }

  # TODO: remove
  scope :with_parent_taxon_name, -> (parent) { where(parent_id: parent) }

  scope :with_base_of_rank_class, -> (rank_class) { where('rank_class LIKE ?', "#{rank_class}%") }
  scope :with_rank_class_including, -> (include_string) { where('rank_class LIKE ?', "%#{include_string}%") }

  # A specific relationship
  scope :as_subject_with_taxon_name_relationship, -> (taxon_name_relationship) { joins(:taxon_name_relationships).where(taxon_name_relationships: {type: taxon_name_relationship}) }
  scope :as_subject_with_taxon_name_relationship_base, -> (taxon_name_relationship) { includes(:taxon_name_relationships).where('taxon_name_relationships.type LIKE ?', "#{taxon_name_relationship}%").references(:taxon_name_relationships) }
  scope :as_subject_without_taxon_name_relationship_base, -> (taxon_name_relationship) { includes(:taxon_name_relationships).where('(taxon_name_relationships.type NOT LIKE ?) OR (taxon_name_relationships.subject_taxon_name_id IS NULL)', "#{taxon_name_relationship}%").references(:taxon_name_relationships) }
  scope :as_subject_with_taxon_name_relationship_array, -> (taxon_name_relationship_name_array) { includes(:taxon_name_relationships).where('(taxon_name_relationships.type IN (?)) OR (taxon_name_relationships.subject_taxon_name_id IS NULL)', "#{taxon_name_relationship_name_array}%").references(:taxon_name_relationships) }
  scope :as_subject_without_taxon_name_relationship_array, -> (taxon_name_relationship_name_array) { includes(:taxon_name_relationships).where('(taxon_name_relationships.type NOT IN (?)) OR (taxon_name_relationships.subject_taxon_name_id IS NULL)', "#{taxon_name_relationship_name_array}%").references(:taxon_name_relationships) }
  scope :as_subject_with_taxon_name_relationship_containing, -> (taxon_name_relationship) { includes(:taxon_name_relationships).where('taxon_name_relationships.type LIKE ?', "%#{taxon_name_relationship}%").references(:taxon_name_relationships) }
  scope :as_object_with_taxon_name_relationship, -> (taxon_name_relationship) { joins(:related_taxon_name_relationships).where(taxon_name_relationships: {type: taxon_name_relationship}) }
  scope :as_object_with_taxon_name_relationship_base, -> (taxon_name_relationship) { includes(:related_taxon_name_relationships).where('taxon_name_relationships.type LIKE ?', "#{taxon_name_relationship}%").references(:related_taxon_name_relationships) }
  scope :as_object_with_taxon_name_relationship_containing, -> (taxon_name_relationship) { includes(:related_taxon_name_relationships).where('taxon_name_relationships.type LIKE ?', "%#{taxon_name_relationship}%").references(:related_taxon_name_relationships) }

  # @param relationship [Array, String]
  def self.with_taxon_name_relationship(relationship)
    a = TaxonName.joins(:taxon_name_relationships).where(taxon_name_relationships: {type: relationship})
    b = TaxonName.joins(:related_taxon_name_relationships).where(taxon_name_relationships: {type: relationship})
    # Note UNION removes duplicates so this returns unique results.
    TaxonName.from("((#{a.to_sql}) UNION (#{b.to_sql})) as taxon_names")
  end

  scope :with_taxon_name_relationships, -> {
    joins('LEFT OUTER JOIN taxon_name_relationships tnr1 ON taxon_names.id = tnr1.subject_taxon_name_id').
    joins('LEFT OUTER JOIN taxon_name_relationships tnr2 ON taxon_names.id = tnr2.object_taxon_name_id').
    where('tnr1.subject_taxon_name_id IS NOT NULL OR tnr2.object_taxon_name_id IS NOT NULL')
  }
  # *Any* relationship where there IS a relationship for a subject/object/both
  scope :with_taxon_name_relationships_as_subject, -> { joins(:taxon_name_relationships) }
  scope :with_taxon_name_relationships_as_object, -> { joins(:related_taxon_name_relationships) }

  # *Any* relationship where there is NOT a relationship for a subject/object/both
  scope :without_subject_taxon_name_relationships, -> { includes(:taxon_name_relationships).where(taxon_name_relationships: {subject_taxon_name_id: nil}) }
  scope :without_object_taxon_name_relationships, -> { includes(:related_taxon_name_relationships).where(taxon_name_relationships: {object_taxon_name_id: nil}) }

  scope :without_taxon_name_relationships, -> {
    joins('LEFT OUTER JOIN taxon_name_relationships tnr1 ON taxon_names.id = tnr1.subject_taxon_name_id').
    joins('LEFT OUTER JOIN taxon_name_relationships tnr2 ON taxon_names.id = tnr2.object_taxon_name_id').
    where('tnr1.subject_taxon_name_id IS NULL AND tnr2.object_taxon_name_id IS NULL')
  }

  # TODO: deprecate all of these for where()
  scope :with_parent_id, -> (parent_id) {where(parent_id:)}
  scope :with_cached_valid_taxon_name_id, -> (cached_valid_taxon_name_id) {where(cached_valid_taxon_name_id:)}
  scope :with_cached_original_combination, -> (original_combination) { where(cached_original_combination: original_combination) }

  scope :without_otus, -> { includes(:otus).where(otus: {id: nil}) }
  scope :with_otus, -> { includes(:otus).where.not(otus: {id: nil}) }

  # @return [Scope]
  #   Combinations that are composed of children of this taxon name
  #     when those children are not currently descendants of this taxon name
  #
  # !! When :cached_valid_taxon_name_id is properly set then this method is not required
  # rather you should use :historical_taxon_names.
  #
  def self.out_of_scope_combinations(taxon_name_id)
    t = ::TaxonName.arel_table
    h = ::TaxonNameHierarchy.arel_table
    r = ::TaxonNameRelationship.arel_table

    h1 = h.alias('osch_')
    h2 = h.alias('oschh_')

    b = h.project(
      h1[:descendant_id].as('b'),
      h2[:ancestor_id].as('c'),
    ).from([h])

    b = b.join(r, Arel::Nodes::InnerJoin).on(h[:descendant_id].eq(r[:subject_taxon_name_id]).and(h[:ancestor_id].eq(taxon_name_id)))
      .join(h1, Arel::Nodes::InnerJoin).on(r[:object_taxon_name_id].eq(h1[:descendant_id]).and(h1[:ancestor_id].not_eq(h1[:descendant_id])))
      .join(h2, Arel::Nodes::OuterJoin).on(
        h1[:ancestor_id].eq(h2[:ancestor_id]).
        and(h2[:descendant_id].eq(taxon_name_id))
      )

    # This was particularly useful in debugging the join chain:
    # ap TaxonNameHierarchy.connection.execute(b.to_sql).collect{|a| a}

    b = b.as('abc')

    ::Combination
      .joins(Arel::Nodes::InnerJoin.new(b, Arel::Nodes::On.new(b['b'].eq(t[:id]))))
      .where(b['c'].eq(nil))
      .distinct
  end

  # @return Scope
  #   names that are not leaves
  # TODO: belongs in lib/queries/filter.rb likely
  def self.not_leaves
    t = self.arel_table
    h = ::TaxonNameHierarchy.arel_table

    a = t.alias('a_')
    b = t.project(a[Arel.star]).from(a)

    c = h.alias('h1')

    b = b.join(c, Arel::Nodes::OuterJoin)
      .on(
        a[:id].eq(c[:ancestor_id])
      )

    e = c[:generations].not_eq(0)
    f = c[:ancestor_id].not_eq(c[:descendant_id])

    b = b.where(e.and(f))
    b = b.group(a[:id])
    b = b.as('tnh_')

    ::TaxonName.joins(Arel::Nodes::InnerJoin.new(b, Arel::Nodes::On.new(b['id'].eq(t['id']))))
  end

  soft_validate(
    :sv_missing_confidence_level,
    set: :missing_fields,
    name: 'Missing confidence level',
    description: 'To remaind that the taxon spelling have to be compared to the original source' )

  soft_validate(
    :sv_missing_original_publication,
    set: :missing_fields,
    name: 'Missing original source',
    description: 'Original source is not selected' )

  soft_validate(
    :sv_parent_is_valid_name,
    set: :parent_is_valid_name,
    fix: :sv_fix_parent_is_valid_name,
    name: 'Parent should be a valid taxon',
    description: 'When the parent taxon (for example a genus) is treated as a synonym, all subordinate taxa from this taxon should be transferred to the valid taxon' )

  soft_validate(
    :sv_conflicting_subordinate_taxa,
    set: :parent_is_valid_name,
    name: 'Conflicting subordinate taxa',
    description: 'Unavailable or invalid taxon should not have subordinate taxa' )

  soft_validate(
    :sv_cached_names,
    set: :cached_names,
    fix: :sv_fix_cached_names,
    name: 'Cached names',
    description: 'Check if cached values need to be updated' )

  # TODO: move to protonym spec?
  soft_validate(
    :sv_not_synonym_of_self,
    set: :not_synonym_of_self,
    name: 'Not synonym of self',
    description: 'Taxon has two conflicting relationships (invalidating and validating).' )

  # TODO: move to protonym spec?
  soft_validate(
    :sv_two_unresolved_alternative_synonyms,
    set: :two_unresolved_alternative_synonyms,
    name: 'Two conflicting relationships',
    description: 'Taxon has two conflicting relationships.' )

  # TODO: move to combination spec?
  soft_validate(
    :sv_incomplete_combination,
    set: :incomplete_combination,
    name: 'Incomplete combination',
    description: 'Intermediate ranks are missing in combination (either original or subsequent)' )

  # @return [Array of TaxonName]
  #   ordered by rank, a scope-like hack
  def self.sort_by_rank(taxon_names)
    taxon_names.sort!{|a, b| RANKS.index(a.rank_string) <=> RANKS.index(b.rank_string)}
  end

  # TODO: what is this:!? :)
  # def self.foo(rank_classes)
  #   from <<-SQL.strip_heredoc
  #     ( SELECT *, rank()
  #          OVER (
  #              PARTITION BY rank_class, parent_id
  #              ORDER BY generations asc, name
  #           ) AS rn
  #        FROM taxon_names
  #        INNER JOIN "taxon_name_hierarchies" ON "taxon_names"."id" = "taxon_name_hierarchies"."descendant_id"
  #        WHERE #{rank_classes.collect{|c| "rank_class = '#{c}'" }.join(' OR ')}
  #        ) as taxon_names
  #   SQL
  # end

  # See attr_reader.
  def taxonomy(rebuild = false)
    if rebuild
      @taxonomy = full_name_hash
    else
      @taxonomy ||= full_name_hash
    end
  end

  def relationships(rebuild = false)
    if rebuild
      @relationships = taxon_name_relationships.eager_load(:subject_taxon_name, :object_taxon_name).to_a
    else
      @relationships ||= taxon_name_relationships.eager_load(:subject_taxon_name, :object_taxon_name).to_a
    end
  end

  def related_relationships(rebuild = false)
    if rebuild
      @related_relationships = related_taxon_name_relationships.eager_load(:subject_taxon_name, :object_taxon_name).to_a
    else
      @related_relationships ||= related_taxon_name_relationships.eager_load(:subject_taxon_name, :object_taxon_name).to_a
    end

    @related_relationships
  end

  def classifications(rebuild = false)
    if rebuild
      @classifications = taxon_name_classifications.to_a
    else
      @classifications ||= taxon_name_classifications.to_a
    end
  end

  # @return [Scope] Protonym(s) the **broad sense** synonyms of this name
  def synonyms
    TaxonName.with_cached_valid_taxon_name_id(id)
  end

  # @return [String]
  #   rank as human readable short-form, like 'genus' or 'species'
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

  # @see .out_of_scope_combinations
  def out_of_scope_combinations
    ::TaxonName
      .where(project_id:)
      .out_of_scope_combinations(id)
  end

  # TODO !!: replace with @taxonomy
  # @return [TaxonName, nil] an ancestor at the specified rank
  # @param rank [symbol|string]
  #   like :species or 'genus'
  # @param include_self [Boolean]
  #   if true then self will also be returned
  def ancestor_at_rank(rank, include_self = false)
    if target_code = (is_combination? ? combination_taxon_names.first.nomenclatural_code : nomenclatural_code)
      r = Ranks.lookup(target_code, rank)
      return self if include_self && (rank_class.to_s == r)
      ancestors
        .unscope(:order) # 24s to 14 savings
        .with_rank_class( r )
        .first
    else
      # Root has no nomenclature code
      return nil
    end
  end

  # Unused
  # @return scope [TaxonName, nil] an ancestor at the specified rank
  # @params rank [symbol|string|
  #   like :species or 'genus'
  # def descendants_at_rank(rank)
  #   return TaxonName.none if nomenclatural_code.blank? # Root names
  #   descendants.with_rank_class(
  #     Ranks.lookup(nomenclatural_code, rank)
  #   )
  # end

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
    TaxonName.find_by_sql(
      "SELECT tn.* from taxon_names tn join taxon_name_relationships tnr1 on tn.id = tnr1.subject_taxon_name_id and tnr1.object_taxon_name_id = #{self.id}
       UNION
       SELECT tn.* from taxon_names tn join taxon_name_relationships tnr2 on tn.id = tnr2.object_taxon_name_id and tnr2.subject_taxon_name_id = #{self.id}"
    )
  end

  # @return [String, nil]
  #   the baseline means of displaying name authorship, i.e. the author for this taxon, last name only.
  # Important, string format priority is
  #   1) as provided verbatim
  #   2) as generated from People
  #   3) as taken from the Source
  #       Source People (Authors)
  #       Source Verbatim authors
  def author_string
    return verbatim_author if !verbatim_author.nil?
    if taxon_name_authors.any?
      return Utilities::Strings.authorship_sentence( taxon_name_authors.pluck(:last_name) )
    end

    return source.authority_name if !source.nil?
    nil
  end

#    @real=6.90503800008446,
#  @stime=0.23281300000000016,
#  @total=3.0006990000000044,
#  @utime=2.7678860000000043>

  # @return [Integer]
  #   a 4 digit integer representing year of publication, like 1974
  def year_integer
    return year_of_publication if !year_of_publication.nil?
    try(:source).try(:year)
  end

  # @return Year,nil
  #  based on TaxonNameRelationships only at present
  def taxon_name_relationship_minimum_invalidating_year
    a = taxon_name_relationships.joins(:source).where(type: ::TAXON_NAME_RELATIONSHIP_NAMES_SYNONYM).order('sources.year ASC').first
    a&.nomenclature_date&.year == Date.current.year ? nil : a&.nomenclature_date&.year
  end

  # TODO: @proceps write test please)
  def taxon_name_classification_minimum_invalidating_year
    # TODO: Refactor to youngest()
    a = taxon_name_classifications.includes(:source).order_by_oldest_source_first.with_type_array(::TAXON_NAME_CLASS_NAMES_UNAVAILABLE_AND_INVALID).first
    if a
      b = a.nomenclature_date&.year
      if b == Date.current.year
        return nil
      else
        b
      end
    else
      nil
    end
  end

  def minimum_invalidating_year
    [ taxon_name_classification_minimum_invalidating_year, taxon_name_relationship_minimum_invalidating_year ].compact.sort.first
  end

  def minimum_years_valid
    a = [year_integer, minimum_invalidating_year].compact
    if a.size == 2
      a.second - a.first
    else
      nil
    end
  end

  # TODO: cleanly isolate getters, setters, and cached builders
  # TODO: remove, this is only used for a strange call in sv_checked cached.
  #
  # @return String, nil
  #   virtual attribute, to ultimately be fixed in db
  def get_author
    a = cached_author_year.to_s.gsub(/,\s\(?\d+\)?\s\[\d+\]|,\s\(?\d+\)?/, '').gsub(') ', ', ').gsub('(', '').gsub(')', '')
    return nil if a.blank?
    a
  end

  # @return [Time]
  #   effective date of publication, used to determine nomenclatural priority
  #
  # !! Overrides *and* references Shared::Citations#nomenclature_date
  def nomenclature_date
    return nil if !persisted?

    if is_protonym?
      if is_family_rank?
        family_before_1961 = TaxonNameRelationship::Iczn::PotentiallyValidating::FamilyBefore1961.where_subject_is_taxon_name(self).first
      end
    end

    if family_before_1961.nil?
      if a = source_nomenclature_date # Alias for nomenclature_date in shared/citations.rb
        a
      else
        year_of_publication ? Time.utc(year_of_publication, 12, 31) : nil
      end
    else
      obj = family_before_1961.object_taxon_name
      year = obj.year_of_publication ? Time.utc(obj.year_of_publication, 12, 31) : nil
      b = obj.source_nomenclature_date
      b ? b : year
    end
  end

  # TODO:  Belongs in catatlog or helper
  # @return [array]
  # returns array of hashes for history of taxon. Could be used for catalogue construction.
  def nomeclatural_history
    h = []
    TaxonName.where(cached_valid_taxon_name_id: self.id).order(:cached_nomenclature_date).each do |t|
      item = {}
      source_author_string = t.is_combination? ? [t.origin_citation&.source&.authority_name, t.origin_citation&.source&.year].join(', ') : nil
      source_author_string = ' in ' + source_author_string unless source_author_string.nil?
      item[:name] = t.is_combination? ? t.cached_html : t.cached_original_combination_html
      item[:author_year] = t.is_combination? ? t.cached_author_year + source_author_string : t.original_author_year
      item[:statuses] = t.combined_statuses
      h.append(item)
    end
    return h
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
  #   the unique string labels (human readable) derived from TaxonNameClassifications
  def statuses_from_classifications
    list = taxon_name_classifications_for_statuses
    list.empty? ? [] : list.collect{|c| c.classification_label }.sort
  end

  # @return [Scope]
  def taxon_name_classifications_for_statuses
    taxon_name_classifications.with_type_array(
      ICZN_TAXON_NAME_CLASSIFICATION_NAMES +
      ICN_TAXON_NAME_CLASSIFICATION_NAMES +
      ICNP_TAXON_NAME_CLASSIFICATION_NAMES +
      ICVCN_TAXON_NAME_CLASSIFICATION_NAMES)
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
  #   All of the names this name has been in combination with
  def combination_list_all
    taxon_name_relationships.with_type_base('TaxonNameRelationship::Combination').collect {|r| r.object_taxon_name}.uniq
  end

  # @return [Array of Protonym]
  #   for all names this name has been in combination with, select those names that are of the same rank (!! CONFIRM?)
  def combination_list_self
    combination_list_all.select{|c| c.protonyms_by_rank[c.protonyms_by_rank.keys.last] == self}
  end

  # TODO: should be moved to helpers
  # and referenced in models with helper.

  # TODO: in refactor these are often just helper methods ,
  # though variously used in soft_validations
  # (and various are only used in helpers already)

  # TODO: helper/render?
  # @return [String]
  #   combination of cached_html and cached_author_year.
  def cached_html_name_and_author_year
    [cached_html, cached_author_year].compact.join(' ')
  end

  # @return [String]
  #   combination of cached_original_combination_html and original_author_year.
  def cached_html_original_name_and_author_year
    [cached_original_combination_html, original_author_year].compact.join(' ')
  end

  # @return [String] combination of cached and cached_author_year.
  def cached_name_and_author_year
    [cached, cached_author_year].compact.join(' ')
  end

  # @return [String, nil]
  #  Derived from cached_author_year
  #  The intent is to remove outer parens for an original combination.
  #
  #   !! DO NOT USE IN BUILDING CACHED !!
  #
  #   See also app/helpers/taxon_names_helper
  #   !! TODO: needs tests badly
  #   !? TODO: cached_author_year should not include `non` likely
  #   !!    i.e. it currently differs from cached_author + cached_nomenclature_date.year
  def original_author_year
    return nil unless cached_author_year

    case nomenclatural_code
    when :iczn

      # Only remove if first and last paren if like this:
      # (Baker, 1899)
      # Not like this:
      # (Baker, 1899) non Gillette, 1898

      return cached_author_year if cached_misspelling

      if cached_author_year =~ /^\((.*)\)$/
        return $1
      end
    when :icn
      # TODO: example text in spec
      if matchdata1 = cached_author_year.match(/(\(.*\))/)
        return matchdata1[1].gsub(/^\(|\)/, '')
      end
    end

    # This means that misaplied or misspelled names return cached author year
    cached_author_year
  end

  # @return [Array of TaxonName] ancestors of type 'Protonym'
  def ancestor_protonyms
    Protonym.ancestors_of(self)
  end

  # @return [Array of TaxonName] descendants of type 'Protonym'
  def descendant_protonyms
    Protonym.descendants_of(self)
  end

  # @return [Boolean]
  #   true if there is a relationship where then name is asserted to be invalid
  def relationship_invalid?
    !first_possible_invalid_taxan_name_relationship.nil?
  end

  # @return [Boolean]
  #  true if this name has any classification asserting that it is valid
  def classification_valid?
    taxon_name_classifications.with_type_array(TAXON_NAME_CLASS_NAMES_VALID).any?
  end

  # @return [Boolean]
  #  whether this name has any classification asserting that this the name is NOT valid or that it is unavailable
  def classification_invalid_or_unavailable?
    taxon_name_classifications.with_type_array(TAXON_NAME_CLASS_NAMES_UNAVAILABLE_AND_INVALID).any?
  end

  # @return [Boolean]
  #  whether this name has any classification asserting that this the name is unavailable
  def classification_unavailable?
    taxon_name_classifications.with_type_array(TAXON_NAME_CLASS_NAMES_UNAVAILABLE).any?
  end

  #  @return [Boolean]
  #     return true if name is unavailable OR invalid, else false, checks both classifications and relationships
  # !! Should only be referenced when building cached values, all other uses should rather be `!is_valid?`
  def unavailable_or_invalid?
    return false if classification_valid?
    classification_invalid_or_unavailable? || relationship_invalid?
  end

  # @return [Boolean]
  #   after all inference on the validity of a name, the result is stored
  #   in cached_valid_taxon_name_id, #is_valid checks that result
  def is_valid?
    cached_is_valid
  end

  # @return [Boolean]
  #   after all inference on the validity of a name, the result is stored
  def is_available?
    cached_is_available
  end

  # Has Classification, but no relationship describing why
  def is_ambiguously_invalid?
    !is_valid? && (id == cached_valid_taxon_name_id)
  end

  # @return [Boolean]
  #   whether this name needs italics applied
  def is_italicized?
    is_genus_or_species_rank? || kind_of?(Combination) || kind_of?(Hybrid)
  end

  def is_protonym?
    type == 'Protonym'
  end

  def is_combination?
    type == 'Combination'
  end

  # @return [True|False]
  #   true if this name has a TaxonNameClassification of Fossil
  # !!# Note that this is not possible for non icn or iczn names yet!
  def is_fossil?
    taxon_name_classifications.with_type_contains('::Fossil').any?
  end

  # TODO: ultimately deprecate for type Hybrid names.
  # @return [Boolean]
  #   true if this name has a TaxonNameClassification of hybrid
  def is_hybrid?
    return false unless rank_string =~  /::Icn::/ # don't make costly check!
    taxon_name_classifications.with_type_contains('Hybrid').any?
  end

  # @return [True|False]
  #   true if this name has a TaxonNameClassification of candidatus
  def is_candidatus?
    return false unless rank_string =~ /Icnp/
    taxon_name_classifications.with_type_contains('Candidatus').any?
  end

  # @return [True|False]
  #   true if this name has a TaxonNameClassification of not_binominal
  # Only applicable to ICN names!
  def not_binominal?
    # return false unless rank_string =~  /::Icn::/ # don't make costly check! TODO: interwined with TNC
    taxon_name_classifications.with_type_contains('NonBinominal').any?
  end

  # @return [Boolean]
  #  see subclasses
  def is_genus_or_species_rank?
    false
  end

  # @return [TaxonName]
  #  a valid taxon_name for an invalid name or self for valid name.
  #  a stub here -  See Protonym and Combination
  def get_valid_taxon_name
    nil
  end

  # TODO: remove reloads

  # TODO: write test
  # @return [TaxonNameRelationship]
  #  returns youngest taxon name relationship where self is the subject.
  def first_possible_valid_taxon_name_relationship
  # TaxonNameRelationship.youngest(
  #  taxon_name_relationships.with_type_array(::TAXON_NAME_RELATIONSHIP_NAMES_SYNONYM) # .reload
  # )
    taxon_name_relationships.reload.with_type_array(::TAXON_NAME_RELATIONSHIP_NAMES_SYNONYM).youngest_by_citation
  end

  # TODO: Write test
  def first_possible_invalid_taxan_name_relationship
    # TaxonNameRelationship.youngest(taxon_name_relationships.with_type_array(TAXON_NAME_RELATIONSHIP_NAMES_INVALID)) # .reload
    taxon_name_relationships.reload.with_type_array(TAXON_NAME_RELATIONSHIP_NAMES_INVALID).youngest_by_citation
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
  # Can't we just use #valid_id now?
  # DD: no this is used for validation of multiple conflicting relationships
  #   this list does not return Combinations
  def list_of_invalid_taxon_names
    first_pass = true
    list = {}
    while first_pass || !list.keys.select{|t| list[t] == false}.empty? do
      first_pass = false

      list_of_taxa_to_check = list.empty? ? [self] : list.keys.select{|t| list[t] == false}

      list_of_taxa_to_check.each do |t|
        potentialy_invalid_relationships = t.related_taxon_name_relationships.with_type_array(::TAXON_NAME_RELATIONSHIP_NAMES_SYNONYM).order_by_oldest_source_first
        potentialy_invalid_relationships.each do |r|
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
    list.sort_by{|t, a| (t.cached_nomenclature_date&.to_time || Time.zone.now)}.collect{|t, a| t}
  end

  # TODO: belongs in export
  def gbif_status_array
    return nil if self.class.nil?
    return ['combination'] if self.class == 'Combination'
    s1 = taxon_name_classifications.collect{|c| c.class.gbif_status}.compact
    return s1 unless s1.empty?
    s2 = taxon_name_relationships.collect{|r| r.class.gbif_status_of_subject}
    s3 = related_taxon_name_relationships.collect{|r| r.class.gbif_status_of_object}

    s = s2 + s3
    s.compact!
    return ['valid'] if s.empty?
    s
  end

  def dwc_occurrences
    ::Queries::DwcOccurrence::Filter.new(taxon_name_id: id).all
  end

  def clear_cached(update: false)
    assign_attributes(
      cached_html: nil,
      cached_author_year: nil,
      cached_author: nil,
      cached_original_combination_html: nil,
      cached_secondary_homonym: nil,
      cached_primary_homonym: nil,
      cached_secondary_homonym_alternative_spelling: nil,
      cached_primary_homonym_alternative_spelling: nil,
      cached_misspelling: nil,
      cached_classified_as: nil,
      cached: nil,
      cached_valid_taxon_name_id: nil,
      cached_is_valid: nil,
      cached_original_combination: nil,
      cached_nomenclature_date: nil,
      cached_gender: nil,
      cached_is_available: nil,
    )
    save if update
  end

  def full_name
    ::Utilities::Nomenclature.full_name(full_name_hash)
  end

  # TODO: We need to isolate this into 2 subclasses,
  # 1 - cached methods that touch author/year
  # 2 - cached methods that do not
  def set_cached
    return true if destroyed?
    n = get_full_name # memoize/var into taxonomy?
    update_column(:cached, n)

    # This isn't true according to tests, will be removed shortly.
    #   Import and in-memory requirements should use other checks/auditing.
    #
    # Combination should have its own cached setting methods
    # We can't use the in-memory cache approach for Combinations, force reload each time
    # n = nil if is_combination?

    update_columns(
      cached_html: get_full_name_html(n)
    )

    # one more query, but can be isolated now
    set_cached_nomenclature_date

    # Dependent on TaxonNameClassification and TaxonNameRelationship
    # !! Technically these should not be here.

    # TODO: Isolate and optimize. These an be isolated as they are not always pertinent to a generalized cascading cache setting
    # For example, when a TaxonName relationship forces a cached reload it may/not need to call these two things

    set_cached_valid_taxon_name_id
    set_cached_is_valid
    set_cached_is_available
    set_cached_classified_as

    set_cached_author_columns
  end

  def set_cached_nomenclature_date
    update_columns(cached_nomenclature_date: nomenclature_date)
  end

  # See TaxonNameAuthor
  def set_cached_author_columns
    # TODO: build author year from cached author and year, not the other way around
    #  * at this point we have already updated date
    set_cached_author_year
    set_cached_author # should be after the 'set_cached_author_year
  end

  def set_cached_valid_taxon_name_id
    update_column(:cached_valid_taxon_name_id, get_valid_taxon_name.id)
  end

  def set_cached_is_valid
    v = is_combination? ? false : !unavailable_or_invalid?
    update_column(:cached_is_valid, v)
  end

  def set_cached_is_available
    # TODO: @proceps vs. hybrids? Confirm combinations, Hybrid class vs. TaxonName Hybrid
    v = (is_combination? || is_hybrid?) ? false : get_is_available
    update_column(:cached_is_available, v)
  end

  def set_cached_warnings
    update_columns(
      cached: NO_CACHED_MESSAGE,
      cached_author_year: NO_CACHED_MESSAGE,
      cached_author: NO_CACHED_MESSAGE,
      cached_nomenclature_date: NO_CACHED_MESSAGE,
      cached_classified_as: NO_CACHED_MESSAGE,
      cached_html: NO_CACHED_MESSAGE
    )
  end

  def set_cached_author_year
    update_column(:cached_author_year, get_author_and_year)
  end

  def set_cached_author
    update_column(:cached_author, get_author)
  end

  def set_cached_classified_as
    update_column(:cached_classified_as, get_cached_classified_as)
  end

  # @proceps I feel this needs to go away.  If you want to define misspelling you can not use a verbatim_name. In general
  # verbatim_name should not have downstream factual consequences.
  #
  # TODO:  Missing specs
  def get_cached_misspelling
    misspelling = taxon_name_relationships.with_type_array(TAXON_NAME_RELATIONSHIP_NAMES_MISSPELLING_ONLY).first
    unless misspelling.nil?
      n1 = verbatim_name? ? verbatim_name : name
      n2 = misspelling.object_taxon_name.verbatim_name? ? misspelling.object_taxon_name.verbatim_name : misspelling.object_taxon_name.name
      return true if n1 != n2
    end
    nil
  end

  # Stub, see subclasses
  # TaxonNameRelationships call it for Combinations
  def get_original_combination
    nil
  end

  # Stub, see subclasses
  #   only Protonym, but TaxonNameRelationships call it for Combinations
  def get_original_combination_html
    nil
  end

  # @return [Array]
  #   of TaxonName
  #   same as self.ancestors.to_a, but also works
  #    for new records when parents specified
  def ancestors_through_parents(result = [self], start = self)
    if start.parent.nil?
      return result.reverse
    elsif result.include?(start.parent)
      raise  TaxonWorks::Error, 'parents contain infinfinte loop'
    else
      result << start.parent
      ancestors_through_parents(result, start.parent)
    end
  end

  # TODO: Integrate with Taxonomy?
  #   Taxonomy.values
  #
  # @return [Array of TaxonName]
  #   an list of ancestors, Root first
  #
  # Uses parent recursion when record is new and awesome_nested_set
  # index is not yet usable.
  #
  def safe_self_and_ancestors
    if new_record?
      ancestors_through_parents
    else
      self_and_ancestors
        .unscope(:order)
        .order(generations: :DESC)
        .to_a
    end
  end

  # @return [ rank, prefix, name], ...] for genus and below
  # @taxon_name.full_name_array # =>
  #   [ ["genus", [nil, "Aus"]],
  #     ["subgenus", [nil, "Aus"]],
  #  "section"=>["sect.", "Aus"], "series"=>["ser.", "Aus"], "species"=>[nil, "aaa"], "subspecies"=>[nil, "bbb"], "variety"=>["var.", "ccc"]\}
  def full_name_array
    gender = nil
    data = []

    safe_self_and_ancestors.each do |i|
      rank = i.rank
      gender = i.cached_gender if rank == 'genus'
      method = "#{rank.gsub(/\s/, '_')}_name_elements"
      data.push([rank] + send(method, i, gender)) if self.respond_to?(method)
    end
    data
  end

  # @return Hash
  #  { 'family' => 'Aidae', ...}
  def ancestor_hash
    h = {}
    safe_self_and_ancestors.each do |n|
      h[n.rank] = n.name
    end
    h
  end

  # return [String, nil, false] # TODO: fix
  def get_genus_species(genus_option, self_option)
    # see Protonym
    true
  end

  # TODO: needs test
  # return [Boolean]
  #   whether there is an ICZN missapplication relationship present on this name
  def name_is_misapplied?(relationships = nil )
    relationships ||= taxon_name_relationships
    return true if relationships.pluck(:type).include?('TaxonNameRelationship::Iczn::Invalidating::Misapplication')
    false
  end

  # return [String]
  #   the author and year of the name, adds parenthesis where asserted
  def get_author_and_year
    if self.type == 'Combination'
      c = protonyms_by_rank
      return nil if c.empty?
      taxon = c[c.keys.last]
    else
      taxon = self
    end

    case taxon.rank_class.try(:nomenclatural_code)
    when :iczn
      ay = iczn_author_and_year(taxon)
    when :icvcn
      ay = icn_author_and_year(taxon)
    when :icnp
      ay = icn_author_and_year(taxon)
    when :icn
      ay = icn_author_and_year(taxon)
    else
      ay = ([author_string] + [cached_nomenclature_date&.year]).compact.join(' ')
    end
    (ay.presence)
  end

  def icn_author_and_year(taxon)
    ay = nil

    misapplication = TaxonNameRelationship.where_subject_is_taxon_name(taxon).with_type_string('TaxonNameRelationship::Icn::Unaccepting::Misapplication')
    misspelling = TaxonNameRelationship.where_subject_is_taxon_name(taxon).with_type_array(TAXON_NAME_RELATIONSHIP_NAMES_MISSPELLING_AUTHOR_STRING)
    originally_invalid = TaxonNameRelationship.where_object_is_taxon_name(taxon).with_type_string('TaxonNameRelationship::Icn::Unaccepting::OriginallyInvalid').first
    m_obj = misapplication.empty? ? nil : misapplication.first.object_taxon_name
    mobj = misspelling.empty? ? taxon : misspelling.first.object_taxon_name
    ay = mobj.try(:author_string) # author string for basionym
    if self.type == 'Combination'
      cc = self
    else
      current_combination = TaxonNameRelationship.where_object_is_taxon_name(mobj).with_type_string('TaxonNameRelationship::CurrentCombination')
      cc = current_combination.empty? ? self : current_combination.first.subject_taxon_name
    end

    unless originally_invalid.nil?
      ay = originally_invalid.subject_taxon_name.try(:author_string).to_s + ' ex ' + ay.to_s
    end

    if self.author_string.present? && mobj.id != cc.id
      ay = '(' + ay.to_s + ') ' + cc.try(:author_string).to_s
    end

    if !misapplication.empty? && m_obj.author_string.present?
      ay += ' non ' + m_obj.author_string
    end

    (ay.presence)
  end

  # @return [String, nil]
  #   the authors, and year, with parentheses as inferred by the data
  def iczn_author_and_year(taxon)
    ay = nil
    p = nil

    misapplication = TaxonNameRelationship.where_subject_is_taxon_name(taxon).with_type_string('TaxonNameRelationship::Iczn::Invalidating::Misapplication')
    misspelling = TaxonNameRelationship.where_subject_is_taxon_name(taxon).with_type_array(TAXON_NAME_RELATIONSHIP_NAMES_MISSPELLING_AUTHOR_STRING)

    mobj = misspelling.empty? ? nil : misspelling.first.object_taxon_name
    if mobj.present?
      a = [mobj.try(:author_string)]
      y = [mobj.try(:year_integer)]
    else
      a = [taxon.try(:author_string)]
      y = [taxon.try(:year_integer)]
    end
    if a[0] =~ /^\(.+\)$/ # (Author)
      a[0] = a[0][1..-2] ## remove parentheses in the author string # TODO: draw from cached_author
      p = true
    else
      p = false
    end

    ay = (a + y).compact.join(', ')

    obj = misapplication.empty? ? nil : misapplication.first.object_taxon_name

    if SPECIES_RANK_NAMES_ICZN.include?(taxon.rank_string)
      if p
        ay = '(' + ay + ')' unless ay.empty?
      else
        og = taxon.original_genus
        if self.type == 'Combination'
          cg = genus
        else
          par = TaxonNameRelationship.where_subject_is_taxon_name(taxon).with_type_array(TAXON_NAME_RELATIONSHIP_NAMES_MISSPELLING_AUTHOR_PARENTHESES).any?
          cg = (par == false && !misspelling.empty?) ? og : ancestor_at_rank('genus')
        end
        if !og.nil? && !cg.nil?
          ay = '(' + ay + ')' if !ay.empty? && og.normalized_genus.id != cg.normalized_genus.id
        end
      end
    elsif FAMILY_RANK_NAMES_ICZN.include?(taxon.rank_string) && !y.empty? && cached_nomenclature_date&.year != y.first && !mobj.present?
      ay = ay + ' [' + cached_nomenclature_date&.year.to_s + ']'
      ay = ay.gsub(' []', '')
    end

    unless misapplication.empty? || obj.author_string.blank?
      ay += ' non ' + ([obj.author_string] + [obj.year_integer]).compact.join(', ')
    end

    (ay.presence)
  end

  # @return Protonym
  def normalized_genus
    misspelling = TaxonNameRelationship.where_subject_is_taxon_name(self).with_type_array(TAXON_NAME_RELATIONSHIP_NAMES_MISSPELLING)
    tn = misspelling.empty? ? self : misspelling.first.object_taxon_name
    return tn.lowest_rank_coordinated_taxon
  end

  # @return [String, nil]
  def get_cached_classified_as
    return nil unless is_protonym? || is_combination?
    # source_classified_as is a method generated through relationships
    r = reload_source_classified_as
    return "(as #{r.name})" if r.present?
    nil
  end

  # TODO: this should be paginated, not all IDs!
  def next_sibling
    if siblings.where(project_id:).any?
      sibs = self_and_siblings.order(:cached).pluck(:id)
      s = sibs.index(id)
      TaxonName.find(sibs[ s + 1] ) if s < sibs.length - 1
    else
      nil
    end
  end

  # TODO: this should be paginated, not all IDs!
  def previous_sibling
    if siblings.where(project_id:).any?
      sibs = self_and_siblings.order(:cached).pluck(:id)

      s = sibs.index(id)
      TaxonName.find(sibs[s - 1]) if s != 0
    else
      nil
    end
  end

  def create_otu
    Otu.create(by: creator, project_id:, taxon_name_id: id)
  end

  # @return [Scope]
  #   All taxon names attached to relationships recently created by user
  def self.used_recently_in_classifications(user_id, project_id)
    TaxonName.where(project_id:, updated_by_id: user_id)
      .joins(:taxon_name_classifications)
      .includes(:taxon_name_classifications)
      .where(taxon_name_classifications: { updated_at: 1.week.ago..Time.now } )
      .order('taxon_name_classifications.updated_at DESC')
  end

  # @return [Scope]
  #   All taxon names attached to relationships recently created by user
  def self.used_recently_in_relationships(user_id, project_id)
    t = TaxonNameRelationship.arel_table
    t1 = t.alias('tnr1')
    t2 = t.alias('tnr2')

    sql = t1[:updated_by_id].eq(user_id).or(t1[:created_by_id].eq(user_id))
      .or(t2[:updated_by_id].eq(user_id).or(t2[:created_by_id].eq(user_id))
         ).to_sql

         sql2 = t1[:updated_at].between( 1.week.ago..Time.now )
           .or( t2[:updated_at].between( 1.week.ago..Time.now ) ).to_sql

         TaxonName.with_taxon_name_relationships
           .where(taxon_names: {project_id:})
           .where(sql2)
           .where(sql)
           .order('taxon_names.updated_at DESC') ## needs optimisation. Does not sort by TNR date
  end

  # @return [Array]
  def self.used_recently(user_id, project_id, target: nil)
    klass, a,b,c = nil, nil, nil, nil
    if target == 'TypeMaterial'
      klass = Protonym
      a = klass.is_species_group.touched_by(user_id).where(project_id:).order(updated_at: :desc).limit(6).to_a
      b = used_recently_in_classifications(user_id, project_id).is_species_group.where(type: klass.name).limit(6).to_a
      c = used_recently_in_relationships(user_id, project_id).is_species_group.where(type: klass.name).limit(6).to_a
    else
      klass = TaxonName
      a = klass.touched_by(user_id).where(project_id:).order(updated_at: :desc).limit(6).to_a
      b = used_recently_in_classifications(user_id, project_id).where(type: klass.name).limit(6).to_a
      c = used_recently_in_relationships(user_id, project_id).where(type: klass.name).limit(6).to_a
    end

    d = [ a,b,c ].flatten.compact.uniq.sort{|e,f| e.cached <=> f.cached}
  end

  # @return [Hash]
  def self.select_optimized(user_id, project_id, target: nil)
    klass = (target == 'TypeMaterial' ? Protonym : TaxonName)
    h = {
      recent: klass.used_recently(user_id, project_id, target: klass.name),
      pinboard: klass.pinned_by(user_id).pinned_in_project(project_id).to_a
    }

    h[:quick] = (klass.pinned_by(user_id).pinboard_inserted.pinned_in_project(project_id).to_a + h[:recent][0..3]).uniq
    h
  end

  # See Shared::MatrixHooks
  # @return [{"matrix_row_item": matrix_column_item, "object": object}, false]
  # the hash corresponding to the keyword used in this tag if it exists
  # !! Assumes it can only be in one matrix, this is wrong !!
  def matrix_row_item
    mri = ObservationMatrixRowItem::TaxonNameRowItem.where(taxon_name_id: id, project_id:).limit(1)

    if mri.any?
      return { matrix_row_item: mri.first, object: taxon_name }
    else
      return false
    end
  end

  #  A reified ID is used when the original combination, which does not yet have its own ID and is not the same as the current classification
  # Some observations:
  #  - reified ids are only for original combinations (for which we have no ID)
  #  - reified ids never reference gender changes because they are always in context of original combination, i.e. there is never a gender change
  # Mental note- consider combination - is_current_placement? (presently excluded in CoL code, which is the correct place to decide that.)
  # Duplicated in COLDP export code
  def reified_id
    return id.to_s if is_combination?
    return id.to_s unless has_alternate_original?
    id.to_s + '-' + Digest::MD5.hexdigest(cached_original_combination)
  end

  # TODO: Deprecate/remove for .unify()
  def merge_to(to_taxon_name, kind)
    @result = {
      failed: 0,
      passed: 0,
      kind:
    }

    case kind
    when :taxon_name_relationships
      all_taxon_name_relationships.each do |r|
        begin
          if r.subject_taxon_name_id == id
            r.update!(subject_taxon_name: to_taxon_name)
          elsif  r.object_taxon_name_id == id
            r.update!(object_taxon_name: to_taxon_name)
          else
            @result[:failed] += 1
          end
          @result[:passed] += 1
        rescue ActiveRecord::RecordInvalid
          @result[:failed] += 1
        end
      end
    else
    end

    @result
  end

  # @param undecorated_name String
  #   required
  #
  # @return String
  #   name is `full_name` in TaxonWorks, a string
  #
  # A slim wrapper around the decorator.
  #
  # Gathers the metdata required to htmlize and decorate the name. This method
  # is only and always used to set cached values, those values are
  # related to the use of get_full_name, therefor we always have a name to start with
  # and decorate.
  #
  # TODO: spawn for each class, combination etc. so that we don't include settings that don't apply.
  #
  def get_full_name_html(undecorated_name = nil)
    ::Utilities::Nomenclature.htmlize(
      undecorated_name,
      italicized: is_italicized?,
      hybrid: is_hybrid?,
      fossil: is_fossil?,
      candidatus: is_candidatus?)
  end

  protected

  def check_for_children
    if leaf?
      true
    else
      errors.add(:base, 'This taxon has children names attached, delete those first.')
      throw :abort
    end
  end

  def validate_parent_from_the_same_project
    if parent && project_id.present?
      errors.add(:project_id, 'The parent taxon is not from the same project') if project_id != parent.project_id
    end
  end

  def validate_root_name_is_root
    errors.add(:parent, "most be empty when name is #{ROOT_NAME}") if !parent.nil?
  end

  # TODO: deprecate here we eliminate TaxonName.new() (is present in Protonym already
  def check_new_parent_class
    if is_protonym? && parent_id != parent_id_was && !parent_id_was.nil? && nomenclatural_code == :iczn
      if old_parent = TaxonName.find_by(id: parent_id_was)
        if (rank_name == 'subgenus' || rank_name == 'subspecies') && old_parent.name == name
          errors.add(:parent_id, "The nominotypical #{rank_name} #{name} can not be moved out of the nominal #{old_parent.rank_name}")
        end
      end
    end
  end

  # See subclasses
  def validate_rank_class_class
    true
  end

  # Note- prior version prevented groups from moving when set in error, and was far too strict
  def check_new_rank_class
    if (rank_class != rank_class_was) && !rank_class_was.nil?

      if rank_class_was == 'NomenclaturalRank' && rank_class_changed?
        errors.add(:rank_class, 'Root can not have a new rank')
        return
      end
    end
  end

  def validate_source_type
    a = source && source.type != 'Source::Bibtex'
    b = origin_citation && origin_citation.try(:source).try(:type) != 'Source::Bibtex'
    if a || b
      errors.add(:base, 'Source must be a Bibtex')
    end
  end

  # TODO: this needs to go.
  def sv_missing_confidence_level # should be removed once the alternative solution is implemented. It is heavily used now.
    confidence_level_array = [93]
    confidence_level_array = confidence_level_array & ConfidenceLevel.where(project_id: self.project_id).pluck(:id)
    soft_validations.add(:base, 'Confidence level is missing') if !confidence_level_array.empty? && (self.confidences.pluck(:confidence_level_id) & confidence_level_array).empty?
  end

  def sv_missing_original_publication
    if rank_class.nil? || is_family_or_genus_or_species_rank?
      if self.source.nil?
        soft_validations.add(:base, 'Original publication is not selected')
      elsif self.origin_citation.try(:pages).blank?
        soft_validations.add(:base, 'Original citation pages are not recorded')
      elsif self.source.pages.present?
        matchdata1 = self.origin_citation.pages.match(/^(\d+) ?[-–] ?(\d+)$|^(\d+)$/)
        if matchdata1
          citMinP = matchdata1[1] ? matchdata1[1].to_i : matchdata1[3].to_i
          citMaxP = matchdata1[2] ? matchdata1[2].to_i : matchdata1[3].to_i
          matchdata = self.source.pages.match(/(\d+) ?[-–] ?(\d+)|(\d+)/)
          if citMinP && citMaxP && matchdata
            minP = matchdata[1] ? matchdata[1].to_i : matchdata[3].to_i
            maxP = matchdata[2] ? matchdata[2].to_i : matchdata[3].to_i
            minP = 1 if minP == maxP && %w{book booklet manual mastersthesis phdthesis techreport}.include?(self.source.bibtex_type)
            unless (maxP && minP && minP <= citMinP && maxP >= citMaxP)
              soft_validations.add(:base, 'Original citation could be out of the source page range')
            end
          end
        end
      end
    end
  end

  # def sv_missing_author
  #   true # see Protonym
  # end
  #
  # def sv_missing_year
  #   true # see Protonym
  # end

  def sv_missing_etymology
    true # see Protonym
  end

  def sv_parent_is_valid_name
    if !parent.nil? && parent.unavailable_or_invalid?
      soft_validations.add(:parent_id, 'Parent should be a valid taxon', success_message: 'Parent was updated', failure_message:  'Failed to update parent')
    end
  end

  def sv_fix_parent_is_valid_name
    res = false
    if self.parent.unavailable_or_invalid?
      new_parent = self.parent.get_valid_taxon_name
      if self.parent != new_parent
        self.parent = new_parent
        if self.parent.rank_class.parent.to_s == 'NomenclaturalRank::Iczn::GenusGroup' && self.rank_class.to_s == 'NomenclaturalRank::Iczn::SpeciesGroup::Subspecies'
          self.rank_class = 'NomenclaturalRank::Iczn::SpeciesGroup::Species'
        elsif self.parent.rank_class.parent.to_s == 'NomenclaturalRank::Iczn::FamilyGroup' && self.rank_class.to_s == 'NomenclaturalRank::Iczn::GenusGroup::Subgenus'
          self.rank_class = 'NomenclaturalRank::Iczn::GenusGroup::Genus'
        end

        # TODO: This doesn't ever hit rescue (save doesn't raise), and save can be invalid, and therefor false not true?
        begin
          TaxonName.transaction do
            self.save
            res = true
          end
        rescue
        end
      end
    end
    res
  end

  def sv_conflicting_subordinate_taxa
    classifications = self.taxon_name_classifications.reload
    classification_names = classifications.map { |i| i.type_name }
    compare = TAXON_NAME_CLASS_NAMES_UNAVAILABLE_AND_INVALID & classification_names
    unless compare.empty?
      unless Protonym.with_parent_taxon_name(self).without_taxon_name_classification_array(TAXON_NAME_CLASS_NAMES_UNAVAILABLE_AND_INVALID).empty?
        compare.each do |i|
          # taxon is unavailable or invalid, but has valid children
          soft_validations.add(:base, "Taxon has a status ('#{i.safe_constantize.label}') conflicting with presence of subordinate taxa")
        end
      end
    end
  end

  # TODO: This can be made more specific, we don't need to call some of the methods in set_cached
  # It also should never be required.
  def sv_fix_cached_names
    begin
      TaxonName.transaction do
        self.set_cached
      end
      true
    rescue
      false
    end
  end

  #  Required for synonyms of synomyms
  def sv_not_synonym_of_self
    if list_of_invalid_taxon_names.include?(self)
      soft_validations.add(:base, "Taxon has two conflicting relationships (invalidating and validating). To resolve a conflict, add a status 'Valid' to a valid taxon.")
    end
  end

  def sv_two_unresolved_alternative_synonyms
    r = taxon_name_relationships.includes(:source).order_by_oldest_source_first.with_type_array(::TAXON_NAME_RELATIONSHIP_NAMES_SYNONYM)
    if r.to_a.size > 1
      if r.first.nomenclature_date.to_date == r.second.nomenclature_date.to_date
        soft_validations.add(:base, 'Taxon has two alternative invalidating relationships with identical dates. To resolve ambiguity, add original sources to the relationships with different priority dates.')
      end
    end
  end

  # TODO: Split and move components to Combination
  def sv_incomplete_combination
    soft_validations.add(:base, 'The genus in the combination is not specified') if !cached.nil? && cached.include?('GENUS NOT SPECIFIED')
    soft_validations.add(:base, 'The species in the combination is not specified') if !cached.nil? && cached.include?('SPECIES NOT SPECIFIED')
    soft_validations.add(:base, 'The variety in the combination is not specified') if !cached.nil? && cached.include?('VARIETY NOT SPECIFIED')
    soft_validations.add(:base, 'The form in the combination is not specified') if !cached.nil? && cached.include?('FORM NOT SPECIFIED')

    soft_validations.add(:base, 'The genus in the original combination is not specified') if !cached_original_combination.nil? && cached_original_combination.include?('GENUS NOT SPECIFIED')
    soft_validations.add(:base, 'The species in the original combination is not specified') if !cached_original_combination.nil? && cached_original_combination.include?('SPECIES NOT SPECIFIED')
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

  def sv_validate_name
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

end
