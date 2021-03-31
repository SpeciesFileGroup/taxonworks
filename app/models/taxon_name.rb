require_dependency Rails.root.to_s + '/app/models/taxon_name_classification.rb'
require_dependency Rails.root.to_s + '/app/models/taxon_name_relationship.rb'

# A taxon name (nomenclature only). See also NOMEN.
#
# @!attribute name
#   @return [String, nil]
#   the fully latinized string (monomial) of a code governed taxonomic biological name
#   not applicable for Combinations, they are derived from their pieces
#
# @!attribute parent_id
#   @return [Integer]
#   The id of the parent taxon. The parent child relationship is exclusively organizational. All statuses and relationships
#   of a taxon name must be explicitly defined via taxon name relationships or classifications. The parent of a taxon name
#   can be thought of as  "the place where you'd find this name in a hierarchy if you knew literally *nothing* else about that name."
#   In practice read each monomial in the name (protonym or combination) from right to left, the parent is the parent of the last monomial read.
#   There are 3 simple rules for determining the parent of a Protonym or Combination:
#     1) the parent must always be at least one rank higher than the target names rank
#     2) the parent of a synonym (any sense) is the parent of the synonym's valid name
#     3) the parent of a combination is the parent of the highest ranked monomial in the epithet (almost always the parent of the genus)
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
#   a representation of what the Combination (fully spelled out) or Protonym (monomial)
#   *looked like* in its originating publication.
#   The sole purpose of this string is to represent visual differences from what is recorded in the
#   latinized version of the name (Protonym#name, Combination#cached) from what was originally transcribed.
#   This string should NOT include the author year (see verbatim_author and year_of_publication for those data).
#
#   If a subgenus it should ____TODO____ (not?) contain parens.
#
#
# @!attribute etymology
#   @return [String]
#   the derivation and history of the name in written form
#
# @!attribute cached
#   @return [String]
#   Genus-species combination for genus and lower, monomial for higher. The string has NO html, and no author/year.
#
# @!attribute cached_html
#   @return [String]
#   As in `cached` but with <i></i> tags.
#
# @attribute cached_author_year
#   @return [String, nil]
#      author and year string with parentheses where necessary, i.e. with context of present placement for ICZN
#
# @!attribute cached_higher_classification
#   @return [String]
#   a concatenated list of higher rank taxa. !! Currently deprecated.
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

# @!attribute cached_classified_as
#   @return [String]
#   if the name was classified in different group (e.g. a genus placed in wrong family).
#
# @!cached_valid_taxon_name_id
#   @return [Integer]
#   Stores a taxon_name_id of a valid taxon_name based on taxon_name_relationships and taxon_name_classifications.
#
class TaxonName < ApplicationRecord

  # @return class
  #   this method calls Module#module_parent
  # TODO: This method can be placed elsewhere inside this class (or even removed if not used)
  #       when https://github.com/ClosureTree/closure_tree/issues/346 is fixed.
  def self.parent
    self.module_parent
  end

  # Must be before various of these includes, in particular MatrixHooks
  has_closure_tree

  include Housekeeping
  include Shared::DataAttributes
  include Shared::HasRoles
  include Shared::Tags
  include Shared::Identifiers
  include Shared::Notes
  include Shared::Depictions
  include Shared::Citations
  include Shared::Confidences
  include Shared::AlternateValues
  include Shared::HasPapertrail
  include SoftValidation
  include Shared::IsData
  include TaxonName::OtuSyncronization

  include Shared::MatrixHooks::Member
  include Shared::MatrixHooks::Dynamic

  include TaxonName::MatrixHooks

  attr_accessor :foo

  # Allows users to provide arbitrary annotations that "over-ride" rank string
  ALTERNATE_VALUES_FOR = [:rank_class].freeze # !! Don't even think about putting this on `name`

  COMBINATION_ELEMENTS = [:genus, :subgenus, :species, :subspecies, :variety, :subvariety, :form, :subform].freeze

  SPECIES_EPITHET_RANKS = %w{species subspecies variety subvariety form subform}.freeze

  NOT_LATIN = Regexp.new(/[^a-zA-Z|\-]/).freeze # Dash is allowed?

  NO_CACHED_MESSAGE = 'REBUILD PROJECT TAXON NAME CACHE'.freeze

  NOMEN_VALID = {
    icn: 'http://purl.obolibrary.org/obo/NOMEN_0000383',
    icnp: 'http://purl.obolibrary.org/obo/NOMEN_0000081',
    icvcn: 'http://purl.obolibrary.org/obo/NOMEN_0000125',
    iczn: 'http://purl.obolibrary.org/obo/NOMEN_0000224'
  }

  delegate :nomenclatural_code, to: :rank_class, allow_nil: true
  delegate :rank_name, to: :rank_class, allow_nil: true

  # @return [Boolean]
  #   When true, also creates an OTU that is tied to this taxon name
  attr_accessor :also_create_otu

  # @return [Boolean]
  #   When true cached values are not built
  attr_accessor :no_cached

  # TODO: this was not implemented and tested properly
  # I think the intent is *before* save, i.e. the name will change
  # to a new cached value, so let's record the old one
  #  after_save :create_new_combination_if_absent

  after_save :set_cached, unless: Proc.new {|n| n.no_cached || errors.any? }
  after_save :set_cached_warnings, if: Proc.new {|n| n.no_cached }

  after_create :create_otu, if: :also_create_otu

  before_destroy :check_for_children, prepend: true

  validate :validate_rank_class_class,
    # :check_format_of_name,
    :validate_parent_from_the_same_project,
    :validate_parent_is_set,
    :check_new_rank_class,
    :check_new_parent_class,
    :validate_source_type,
    :validate_one_root_per_project

  # TODO: remove, this is handled natively
  validates_presence_of :type, message: 'is not specified'

  validates :year_of_publication, date_year: {min_year: 1000, max_year: Time.now.year + 5}, allow_nil: true
  validates :name, format: { without: /\s/ }

  # TODO: move some of these down to Protonym when they don't apply to Combination

  # TODO: think of a different name, and test
  has_many :historical_taxon_names, class_name: 'TaxonName', foreign_key: :cached_valid_taxon_name_id

  has_many :observation_matrix_row_items, inverse_of: :taxon_name, class_name: 'ObservationMatrixRowItem::Dynamic::TaxonName', dependent: :delete_all
  has_many :observation_matrices, through: :observation_matrix_row_items

  belongs_to :valid_taxon_name, class_name: 'TaxonName', foreign_key: :cached_valid_taxon_name_id
  has_one :source_classified_as_relationship, -> {
    where(taxon_name_relationships: {type: 'TaxonNameRelationship::SourceClassifiedAs'})
  }, class_name: 'TaxonNameRelationship::SourceClassifiedAs', foreign_key: :subject_taxon_name_id

  has_one :source_classified_as, through: :source_classified_as_relationship, source: :object_taxon_name

  has_many :otus, inverse_of: :taxon_name, dependent: :restrict_with_error
  has_many :taxon_determinations, through: :otus
  has_many :collection_objects, through: :taxon_determinations, source: :biological_collection_object
  has_many :related_taxon_name_relationships, class_name: 'TaxonNameRelationship', foreign_key: :object_taxon_name_id, dependent: :restrict_with_error, inverse_of: :object_taxon_name

  has_many :taxon_name_author_roles, class_name: 'TaxonNameAuthor', as: :role_object, dependent: :destroy
  has_many :taxon_name_authors, -> { order('roles.position ASC') }, through: :taxon_name_author_roles, source: :person

  # TODO: Combinations shouldn't have classifications or relationships?  Move to Protonym?
  has_many :taxon_name_classifications, dependent: :destroy, foreign_key: :taxon_name_id, inverse_of: :taxon_name
  has_many :taxon_name_relationships, foreign_key: :subject_taxon_name_id, dependent: :restrict_with_error, inverse_of: :subject_taxon_name

  # NOTE: Protonym subclassed methods might not be nicely tracked here, we'll have to see.  Placement is after has_many relationships. (?)
  accepts_nested_attributes_for :related_taxon_name_relationships, allow_destroy: true, reject_if: proc { |attributes| attributes['type'].blank? || attributes['subject_taxon_name_id'].blank? }
  accepts_nested_attributes_for :taxon_name_authors, :taxon_name_author_roles, allow_destroy: true
  accepts_nested_attributes_for :taxon_name_classifications, allow_destroy: true, reject_if: proc { |attributes| attributes['type'].blank?  }

  scope :that_is_valid, -> { where('taxon_names.id = taxon_names.cached_valid_taxon_name_id') }
  scope :that_is_invalid, -> { where.not('taxon_names.id = taxon_names.cached_valid_taxon_name_id') }

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

  # Includes taxon_name, doesn't order result
  scope :ancestors_and_descendants_of, -> (taxon_name) do
    scoping do
      a = TaxonName.self_and_ancestors_of(taxon_name)
      b = TaxonName.descendants_of(taxon_name)
      TaxonName.from("((#{a.to_sql}) UNION (#{b.to_sql})) as taxon_names")
    end
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
  scope :as_subject_with_taxon_name_relationship_array, -> (taxon_name_relationship_name_array) { includes(:taxon_name_relationships).where('(taxon_name_relationships.type IN (?)) OR (taxon_name_relationships.subject_taxon_name_id IS NULL)', "#{taxon_name_relationship_name_array}%").references(:taxon_name_relationships) }
  scope :as_subject_without_taxon_name_relationship_array, -> (taxon_name_relationship_name_array) { includes(:taxon_name_relationships).where('(taxon_name_relationships.type NOT IN (?)) OR (taxon_name_relationships.subject_taxon_name_id IS NULL)', "#{taxon_name_relationship_name_array}%").references(:taxon_name_relationships) }
  scope :as_subject_with_taxon_name_relationship_containing, -> (taxon_name_relationship) { includes(:taxon_name_relationships).where('taxon_name_relationships.type LIKE ?', "%#{taxon_name_relationship}%").references(:taxon_name_relationships) }
  scope :as_object_with_taxon_name_relationship, -> (taxon_name_relationship) { includes(:related_taxon_name_relationships).where(taxon_name_relationships: {type: taxon_name_relationship}) }
  scope :as_object_with_taxon_name_relationship_base, -> (taxon_name_relationship) { includes(:related_taxon_name_relationships).where('taxon_name_relationships.type LIKE ?', "#{taxon_name_relationship}%").references(:related_taxon_name_relationships) }
  scope :as_object_with_taxon_name_relationship_containing, -> (taxon_name_relationship) { includes(:related_taxon_name_relationships).where('taxon_name_relationships.type LIKE ?', "%#{taxon_name_relationship}%").references(:related_taxon_name_relationships) }

  # @param relationship [Array, String]
  def self.with_taxon_name_relationship(relationship)
    a = TaxonName.joins(:taxon_name_relationships).where(taxon_name_relationships: {type: relationship})
    b = TaxonName.joins(:related_taxon_name_relationships).where(taxon_name_relationships: {type: relationship})
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
  scope :with_parent_id, -> (parent_id) {where(parent_id: parent_id)}
  scope :with_cached_valid_taxon_name_id, -> (cached_valid_taxon_name_id) {where(cached_valid_taxon_name_id: cached_valid_taxon_name_id)}
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
    h3 = h.alias('oschhh_')

    b = h.project(
      # h[Arel.star],
      # r[:subject_taxon_name_id].as('s'),
      # r[:object_taxon_name_id].as('o'),
      # h[:ancestor_id].as('aa'),
      # h[:descendant_id].as('ab'),
      # h1[:ancestor_id].as('a'),
      h1[:descendant_id].as('b'),
      h2[:ancestor_id].as('c'),
      # h2[:descendant_id].as('d')
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

  soft_validate(:sv_validate_name, set: :validate_name, has_fix: false)
  soft_validate(:sv_missing_confidence_level, set: :missing_fields, has_fix: false)
  soft_validate(:sv_missing_original_publication, set: :missing_fields, has_fix: false)
  soft_validate(:sv_missing_author, set: :missing_fields, has_fix: true)
  soft_validate(:sv_missing_year, set: :missing_fields, has_fix: true)
  soft_validate(:sv_missing_etymology, set: :missing_fields, has_fix: false)
  soft_validate(:sv_parent_is_valid_name, set: :parent_is_valid_name, has_fix: true)
  soft_validate(:sv_conflicting_subordinate_taxa, set: :parent_is_valid_name, has_fix: false)
  soft_validate(:sv_cached_names, set: :cached_names, has_fix: true) # some do, some don't
  soft_validate(:sv_not_synonym_of_self, set: :not_synonym_of_self, has_fix: false)
  soft_validate(:sv_two_unresolved_alternative_synonyms, set: :two_unresolved_alternative_synonyms, has_fix: false)
  soft_validate(:sv_incomplete_combination, set: :incomplete_combination, has_fix: false)

  # @return [Array of TaxonName]
  #   ordered by rank, a scope-like hack
  def self.sort_by_rank(taxon_names)
    taxon_names.sort!{|a, b| RANKS.index(a.rank_string) <=> RANKS.index(b.rank_string)}
  end

  # TODO: what is this:!? :)
  def self.foo(rank_classes)
    from <<-SQL.strip_heredoc
      ( SELECT *, rank()
           OVER (
               PARTITION BY rank_class, parent_id
               ORDER BY generations asc, name
            ) AS rn
         FROM taxon_names
         INNER JOIN "taxon_name_hierarchies" ON "taxon_names"."id" = "taxon_name_hierarchies"."descendant_id"
         WHERE #{rank_classes.collect{|c| "rank_class = '#{c}'" }.join(' OR ')}
         ) as taxon_names
    SQL
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
      .where(project_id: project_id)
      .out_of_scope_combinations(id)
  end

  # @return [TaxonName, nil] an ancestor at the specified rank
  # @param rank [symbol|string|
  #   like :species or 'genus'
  # @param include_self [Boolean]
  #   if true then self will also be returned
  def ancestor_at_rank(rank, include_self = false)
    if target_code = (is_combination? ? combination_taxon_names.first.nomenclatural_code : nomenclatural_code)
      r = Ranks.lookup(target_code, rank)
      return self if include_self && (rank_class.to_s == r)
      ancestors.with_rank_class( r ).first
    else
      # Root has no nomenclature code
      return nil
    end
  end

  # @return scope [TaxonName, nil] an ancestor at the specified rank
  # @params rank [symbol|string|
  #   like :species or 'genus'
  def descendants_at_rank(rank)
    return TaxonName.none if nomenclatural_code.blank? # Root names
    descendants.with_rank_class(
      Ranks.lookup(nomenclatural_code, rank)
    )
  end

  # @return [Scope] Protonym(s) the **broad sense** synonyms of this name
  def synonyms
    TaxonName.with_cached_valid_taxon_name_id(id)
  end

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
  # Important, string format priority is 1) as provided verbatim, 2) as generated from people, and 3) as taken from the source.
  def author_string
    return verbatim_author if !verbatim_author.nil?
    if taxon_name_authors.any?
      if !source.nil? && source.authors.collect{|i| i.id} == taxon_name_authors.pluck(:id).to_a
        return source.authority_name if !source.nil?
      else
        return Utilities::Strings.authorship_sentence( taxon_name_authors.pluck(:last_name) )
      end
    end
    return source.authority_name if !source.nil?
    nil
  end

  # @return [Integer]
  #   a 4 digit integer representing year of publication, like 1974
  def year_integer
    return year_of_publication if !year_of_publication.nil?
    try(:source).try(:year)
  end

  # @return String, nil
  #  # virtual attribute, to ultimately be fixed in db
  def cached_year
    a = cached_author_year&.match(/\d{4}/)
    a ? a[0] : nil
  end

  # @return String, nil
  #  # virtual attribute, to ultimately be fixed in db
  def cached_author
    cached_author_year&.gsub(/,\s\d+/, '')
  end

  # !! Overrides Shared::Citations#nomenclature_date
  #
  # @return [Time]
  #   effective date of publication, used to determine nomenclatural priority
  def nomenclature_date
    return nil if self.id.nil?
     family_before_1961 = TaxonNameRelationship.where_subject_is_taxon_name(self).with_type_string('TaxonNameRelationship::Iczn::PotentiallyValidating::FamilyBefore1961').first

    # family_before_1961 = taxon_name_relationships.with_type_string('TaxonNameRelationship::Iczn::PotentiallyValidating::FamilyBefore1961').first
    if family_before_1961.nil?
      year = self.year_of_publication ? Time.utc(self.year_of_publication, 12, 31) : nil
      self.source ? (self.source.cached_nomenclature_date ? self.source.nomenclature_date : year) : year
    else
      obj  = family_before_1961.object_taxon_name
      year = obj.year_of_publication ? Time.utc(obj.year_of_publication, 12, 31) : nil
      obj.source ? (self.source.cached_nomenclature_date ? obj.source.nomenclature_date : year) : year
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

  # @return [String, nil]
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
  #   the unique string labels (human readable) derived from TaxonNameClassifications
  def statuses_from_classifications
    list = taxon_name_classifications_for_statuses
    list.empty? ? [] : list.collect{|c| c.classification_label }.sort
  end

  # @return [Scope]
  def taxon_name_classifications_for_statuses
    taxon_name_classifications.with_type_array(ICZN_TAXON_NAME_CLASSIFICATION_NAMES + ICN_TAXON_NAME_CLASSIFICATION_NAMES + ICNP_TAXON_NAME_CLASSIFICATION_NAMES + ICTV_TAXON_NAME_CLASSIFICATION_NAMES)
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

  # @return [String]
  #   combination of cached_html and cached_author_year.
  def cached_html_name_and_author_year
    [cached_html, cached_author_year].compact.join(' ')
  end

  # @return [String] combination of cached and cached_author_year.
  def cached_name_and_author_year
    [cached, cached_author_year].compact.join(' ')
  end

  # @return [String, nil]
  #   derived from cached_author_year
  #   !! DO NOT USE IN building cached !!
  #   See also app/helpers/taxon_names_helper
  def original_author_year
    if nomenclatural_code == :iczn
      cached_author_year&.gsub(/^\(|\)/, '')
     #cached_author_year&.gsub(/^\(|\)$/, '')
    else
      cached_author_year
    end
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
    taxon_name_classifications.with_type_array(TAXON_NAME_CLASS_NAMES_UNAVAILABLE_AND_INVALID).any?
  end

  #  @return [Boolean]
  #     return true if name is unavailable OR invalid, else false, checks both classifications and relationships
  def unavailable_or_invalid?
    return false if classification_valid?
    classification_invalid_or_unavailable? || relationship_invalid?
  end

  # @return [Boolean]
  #   after all inference on the validity of a name, the result is stored
  #   in cached_valid_taxon_name_id, #is_valid checks that result
  def is_valid?
    id == cached_valid_taxon_name_id
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
  def is_fossil?
    taxon_name_classifications.with_type_contains('::Fossil').any?
  end

  # @return [Boolean]
  #   true if this name has a TaxonNameClassification of hybrid
  def is_hybrid?
    taxon_name_classifications.where_taxon_name(self).with_type_contains('Hybrid').any?
  end

  # @return [True|False]
  #   true if this name has a TaxonNameClassification of candidatus
  def is_candidatus?
    return false unless rank_string =~ /Icnp/
    taxon_name_classifications.where_taxon_name(self).with_type_contains('Candidatus').any?
  end

  # @return [True|False]
  #   true if this name has a TaxonNameClassification of not_binomial
  def not_binomial?
    taxon_name_classifications.where_taxon_name(self).with_type_contains('NonBinomial').any?
  end

  # @return [Boolean]
  #  see subclasses
  def is_genus_or_species_rank?
    false
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
    taxon_name_relationships.reload.with_type_array(TAXON_NAME_RELATIONSHIP_NAMES_SYNONYM).youngest_by_citation
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
  # this list does not return combinations
  def list_of_invalid_taxon_names
    first_pass = true
    list = {}
    while first_pass || !list.keys.select{|t| list[t] == false}.empty? do
      first_pass = false
      list_of_taxa_to_check = list.empty? ? [self] : list.keys.select{|t| list[t] == false}
      list_of_taxa_to_check.each do |t|
        potentialy_invalid_relationships = t.related_taxon_name_relationships.with_type_array(TAXON_NAME_RELATIONSHIP_NAMES_SYNONYM).order_by_oldest_source_first
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
    list.sort_by{|t, a| (t.nomenclature_date || Time.now)}.collect{|t, a| t}
  end

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

  # @return [Array of Strings]
  #   names of all genera where the species was placed
  def name_in_gender(gender = nil)
    case gender
      when 'masculine'
        n = masculine_name
      when 'feminine'
        n = feminine_name
      when 'neuter'
        n = neuter_name
      else
        n = nil
    end
    n = n.blank? ? name : n
    return n
  end

  # def create_new_combination_if_absent
  # return true unless type == 'Protonym'
  # if !TaxonName.with_cached_html(cached_html).count == 0 (was intent to make this always fail?!)
  #
  #  if TaxonName.where(cached: cached, project_id: project_id).any?
  #    begin
  #      TaxonName.transaction do
  #        c = Combination.new
  #        safe_self_and_ancestors.each do |i|
  #          case i.rank
  #            when 'genus'
  #              c.genus = i
  #            when 'subgenus'
  #              c.subgenus = i
  #            when 'species'
  #              c.species = i
  #            when 'subspecies'
  #              c.subspecies = i
  #          end
  #        end
  #        c.save
  #      end
  #    rescue
  #    end
  #    false
  #  end
  # end

  def clear_cached(update: false)
    assign_attributes(
      cached_html: nil,
      cached_author_year: nil,
      cached_original_combination_html: nil,
      cached_secondary_homonym: nil,
      cached_primary_homonym: nil,
      cached_secondary_homonym_alternative_spelling: nil,
      cached_primary_homonym_alternative_spelling: nil,
      cached_misspelling: nil,
      cached_classified_as: nil,
      cached: nil,
      cached_valid_taxon_name_id: nil,
      cached_original_combination: nil,
      cached_nomenclature_date: nil
    )
    save if update
  end

  def set_cached
    n = get_full_name
    update_column(:cached, n)

    # We can't use the in-memory cache approach for combination names, force reload each time
    n = nil if is_combination?

    update_columns(cached_html: get_full_name_html(n),
                   cached_nomenclature_date: nomenclature_date)

    set_cached_valid_taxon_name_id

    # These two can be isolated as they are not always pertinent to a generalized cascading cache setting
    # For example, when a TaxonName relationship forces a cached reload it may/not need to call these two things
    set_cached_classified_as
    set_cached_author_year
  end

  def set_cached_valid_taxon_name_id
    update_column(:cached_valid_taxon_name_id, get_valid_taxon_name.id)
  end

  def set_cached_warnings
    update_columns(
      cached:  NO_CACHED_MESSAGE,
      cached_author_year:  NO_CACHED_MESSAGE,
      cached_nomenclature_date: NO_CACHED_MESSAGE,
      cached_classified_as: NO_CACHED_MESSAGE,
      cached_html:  NO_CACHED_MESSAGE
    )
  end

  def set_cached_author_year
    update_column(:cached_author_year, get_author_and_year)
  end

  def set_cached_classified_as
    update_column(:cached_classified_as, get_cached_classified_as)
  end

  def get_cached_misspelling
    misspelling = TaxonNameRelationship.where_subject_is_taxon_name(self).with_type_array(TAXON_NAME_RELATIONSHIP_NAMES_MISSPELLING_ONLY).first
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
      self.self_and_ancestors.reload.to_a.reverse ## .self_and_ancestors returns empty array!!!!!!!
    end
  end

  # @return [ rank, prefix, name], ...] for genus and below
  # @taxon_name.full_name_array # =>
  #   [ ["genus", [nil, "Aus"]],
  #     ["subgenus", [nil, "Aus"]],
  #  "section"=>["sect.", "Aus"], "series"=>["ser.", "Aus"], "species"=>[nil, "aaa"], "subspecies"=>[nil, "bbb"], "variety"=>["var.", "ccc"]\}
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

  def ancestor_hash
    h = {}
    safe_self_and_ancestors.each do |n|
      h[n.rank] = n.name
    end
    h
  end

  # !! TODO: when name is a subgenus will no grab genus
  #
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

      if i.is_genus_or_species_rank?
        if ['genus', 'subgenus', 'species', 'subspecies'].include? (rank)
          data[rank] = [nil, i.name_with_misspelling(gender)]
        else
          data[rank] = [i.rank_class.abbreviation, i.name_with_misspelling(gender)]
        end
      else
        data[rank] = i.name
      end
    end

    if data['genus'].nil?
      if original_genus
        data['genus'] = [nil, "[#{original_genus&.name}]"]
      else
        data['genus'] = [nil, '[GENUS NOT SPECIFIED]']
      end
    end

    if data['species'].nil? && (!data['subspecies'].nil? || !data['variety'].nil? || !data['subvariety'].nil? || !data['form'].nil? || !data['subform'].nil?)
      data['species'] = [nil, '[SPECIES NOT SPECIFIED]']
    end

    if data['variety'].nil? && !data['subvariety'].nil?
      data['variety'] = [nil, '[VARIETY NOT SPECIFIED]']
    end

    if data['form'].nil? && !data['subform'].nil?
      data['form'] = [nil, '[FORM NOT SPECIFIED]']
    end

    data
  end

  # @return [String]
  #  a monomial if names is above genus, or a full epithet if below.
  def get_full_name
    return name_with_misspelling(nil) if type != 'Combination' && !GENUS_AND_SPECIES_RANK_NAMES.include?(rank_string)
#    return name if not_binomial?
    return name if rank_class.to_s =~ /Icvcn/
    return verbatim_name if !verbatim_name.nil? && type == 'Combination'

    d = full_name_hash
    elements = []
    elements.push(d['genus']) unless (not_binomial? && d['genus'][1] == '[GENUS NOT SPECIFIED]')
    #elements.push ['(', d['subgenus'], d['section'], d['subsection'], d['series'], d['subseries'], ')']
    elements.push ['(', d['subgenus'], ')']
    elements.push ['(', d['infragenus'], ')'] if rank_name == 'infragenus'
    elements.push ['(', d['supergenus'], ')'] if rank_name == 'supergenus'
    elements.push ['(', d['supersubgenus'], ')'] if rank_name == 'supersubgenus'
    elements.push ['(', d['supersupersubgenus'], ')'] if rank_name == 'supersupersubgenus'
    elements.push [d['supersuperspecies']] if rank_name == 'supersuperspecies'
    elements.push [d['superspecies']] if rank_name == 'superspecies'
    elements.push [d['subsuperspecies']] if rank_name == 'subsuperspecies'
    elements.push(d['species'], d['subspecies'], d['variety'], d['subvariety'], d['form'], d['subform'])
    elements = elements.flatten.compact.join(' ').gsub(/\(\s*\)/, '').gsub(/\(\s/, '(').gsub(/\s\)/, ')').squish
    elements.blank? ? nil : elements
  end

  def get_full_name_html(name = nil)
    name = get_full_name if name.nil?
    n = name
    # n = verbatim_name.blank? ? name : verbatim_name
    return  "\"<i>Candidatus</i> #{n}\"" if is_candidatus?
    if !n.blank? && is_hybrid?
      w = n.split(' ')
      w[-1] = ('×' + w[-1]).gsub('×(', '(×')
      n = w.join(' ')
    end
    n = Utilities::Italicize.taxon_name(n) if is_italicized?
    n = '† ' + n if is_fossil?
    n
  end

  # @return [String]
  #    TODO: does this form of the name contain parens for subgenus?
  #    TODO: provide a default to gender (but do NOT eliminate param)
  #    TODO: on third thought- eliminate this mess
  def name_with_misspelling(gender)
    if cached_misspelling
      if rank_string =~ /Icnp/
        name.to_s + ' (sic)'
      else
        name.to_s + ' [sic]'
      end
    elsif gender.nil? || rank_string =~ /Genus/
      name.to_s
    else
      name_in_gender(gender).to_s
    end
  end

  # @return [String, nil]
  def genderized_name(gender = nil)
    if gender.nil? || is_genus_rank?
      name
    else
      name_in_gender(gender)
    end
  end

  # return [String, nil, false] # TODO: fix
  def get_genus_species(genus_option, self_option)
  # see protonym
    true
  end

  # return [Boolean] whether there is missaplication relationship
  def name_is_misapplied?
    !TaxonNameRelationship.where_subject_is_taxon_name(self).with_type_string('TaxonNameRelationship::Iczn::Invalidating::Misapplication').empty?
  end

  # return [String]
  #   the author and year of the name, adds parenthesis where asserted
  #   abstract, see Protonym and Combination
  def get_author_and_year
    true
  end

  def icn_author_and_year
    ay = nil

    basionym = TaxonNameRelationship.where_object_is_taxon_name(self).
      with_type_string('TaxonNameRelationship::Icn::Unaccepting::Usage::Basionym')
    b_sub = basionym.empty? ? nil : basionym.first.subject_taxon_name

    misapplication = TaxonNameRelationship.where_subject_is_taxon_name(self).
      with_type_string('TaxonNameRelationship::Icn::Unaccepting::Misapplication')
    m_obj = misapplication.empty? ? nil : misapplication.first.object_taxon_name

    t  = [self.author_string]
    t  += ['(' + self.year_integer.to_s + ')'] unless self.year_integer.nil?
    ay = t.compact.join(' ')

    unless basionym.empty? || b_sub.author_string.blank?
      ay = '(' + b_sub.author_string + ') ' + ay
    end

    unless misapplication.empty? || m_obj.author_string.blank?
      ay += ' non ' + [m_obj.author_string]
      t  += ['(' + m_obj.year_integer.to_s + ')'] unless m_obj.year_integer.nil?
      ay = t.compact.join(' ')
    end

    ay.blank? ? nil : ay
  end

  # @return [String, nil]
  #   the authors, and year, with parentheses as inferred by the data
  def iczn_author_and_year
    ay = nil
    p = nil

    misapplication = TaxonNameRelationship.where_subject_is_taxon_name(self).with_type_string('TaxonNameRelationship::Iczn::Invalidating::Misapplication')
    misspelling = TaxonNameRelationship.where_subject_is_taxon_name(self).with_type_array(TAXON_NAME_RELATIONSHIP_NAMES_MISSPELLING)

    if self.type == 'Combination'
      c = protonyms_by_rank
      return nil if c.empty?
      taxon = c[c.keys.last]
    else
      taxon = self
    end

    mobj = misspelling.empty? ? nil : misspelling.first.object_taxon_name
    unless mobj.blank?
      a = [mobj.try(:author_string)]
      y = [mobj.try(:year_integer)]
    else
      a = [taxon.try(:author_string)]
      y = [taxon.try(:year_integer)]
    end

    if a[0] =~ /^\(.+\)$/ # (Author)
      a[0] = a[0][1..-2] ## remove parentheses in the author string
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
          cg = ancestor_at_rank('genus')
        end
        unless og.nil? || cg.nil?
          ay = '(' + ay + ')' if !ay.empty? && og.normalized_genus.id != cg.normalized_genus.id
        end
      end
    end

    unless misapplication.empty? || obj.author_string.blank?
      ay += ' non ' + ([obj.author_string] + [obj.year_integer]).compact.join(', ')
    end

    ay.blank? ? nil : ay
  end

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
    return " (as #{r.name})" unless r.blank?
    nil
  end

  # @return [Boolean]
  def parent_is_set?
    !parent_id.nil? || (parent && parent.persisted?)
  end

  def next_sibling
    if siblings.where(project_id: project_id).load.any?
      sibs = self_and_siblings.order(:cached).pluck(:id)
      s = sibs.index(id)
      TaxonName.find(sibs[ s + 1] ) if s < sibs.length - 1
    else
      nil
    end
  end

  def previous_sibling
    if siblings.where(project_id: project_id).load.any?
      sibs = self_and_siblings.order(:cached).pluck(:id)
      s = sibs.index(id)
      TaxonName.find(sibs[s - 1]) if s != 0
    else
      nil
    end
  end

  def create_otu
    Otu.create(by: creator, project: project, taxon_name_id: id)
  end

  # @return [Scope]
  #   All taxon names attached to relationships recently created by user
  def self.used_recently_in_classifications(user_id, project_id)
    TaxonName.where(project_id: project_id, created_by_id: user_id)
      .joins(:taxon_name_classifications)
      .includes(:taxon_name_classifications)
      .where(taxon_name_classifications: { created_at: 1.weeks.ago..Time.now } )
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

    sql2 = t1[:created_at].between( 1.weeks.ago..Time.now )
      .or( t2[:created_at].between( 1.weeks.ago..Time.now ) ).to_sql

    TaxonName.with_taxon_name_relationships
      .where(taxon_names: {project_id: project_id})
      .where(sql2)
      .where(sql)
      .order('taxon_names.updated_at DESC') ## needs optimisation. Does not sort by TNR date
  end

  # @return [Array]
  #   !! not a scope
  def self.used_recently(user_id, project_id)

    # !! If cached of one name is nill the raises an ArgumentError
    a = [
      TaxonName.touched_by(user_id).where(project_id: project_id).order(updated_at: :desc).limit(6).to_a,
      used_recently_in_classifications(user_id, project_id).limit(6).to_a,
      used_recently_in_relationships(user_id, project_id).limit(6).to_a
    ].flatten.compact.uniq.sort{|a,b| a.cached <=> b.cached}
  end

  # @return [Hash]
  def self.select_optimized(user_id, project_id)
    h = {
      recent: TaxonName.used_recently(user_id, project_id),
      pinboard: TaxonName.pinned_by(user_id).pinned_in_project(project_id).to_a
    }

    h[:quick] = (TaxonName.pinned_by(user_id).pinboard_inserted.pinned_in_project(project_id).to_a + h[:recent][0..3]).uniq
    h
  end

  # See Shared::MatrixHooks
  # @return [{"matrix_row_item": matrix_column_item, "object": object}, false]
  # the hash corresponding to the keyword used in this tag if it exists
  # !! Assumes it can only be in one matrix, this is wrong !!
  def matrix_row_item
    mri = ObservationMatrixRowItem::TaxonNameRowItem.where(taxon_name_id: id, project_id: project_id).limit(1)

    if mri.any?
      return { matrix_row_item: mri.first, object: taxon_name }
    else
      return false
    end
  end

  # @return [String]
  #  a reified ID is used when the original combination, which does not yet have it's own ID, is not the same as the current classification
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

  protected

  def check_for_children
    if leaf?
      true
    else
      errors.add(:base, 'This taxon has children names attached, delete those first.')
      throw :abort
    end
  end

  def validate_parent_is_set
    if !(rank_class == NomenclaturalRank) && !(type == 'Combination')
      errors.add(:parent_id, 'is not selected') if !parent_is_set?
    end
  end

  def validate_parent_from_the_same_project
    if parent && !project_id.blank?
      errors.add(:project_id, "The parent taxon is not from the same project") if project_id != parent.project_id
    end
  end

  def validate_one_root_per_project
    if new_record? || parent_id_changed? # project_id !?@
      if !parent_is_set? && TaxonName.where(parent_id: nil, project_id: project_id).count > 0
        errors.add(:parent_id, 'should not be empty/only one root is allowed per project')
      end
    end
  end

  # TODO: move to Protonym when we eliminate TaxonName.new()
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

  #region Soft validation

  def sv_validate_name
    correct_name_format = false

    if rank_class
      # TODO: name these Regexp somewhere
      if (name =~ /^[a-zA-Z]*$/) || # !! should reference NOT_LATIN
          (nomenclatural_code == :iczn && name =~ /^[a-zA-Z]-[a-zA-Z]*$/) ||
          (nomenclatural_code == :icnp && name =~ /^[a-zA-Z]-[a-zA-Z]*$/) ||
          (nomenclatural_code == :icn && name =~  /^[a-zA-Z]*-[a-zA-Z]*$/) ||
          (nomenclatural_code == :icn && name =~  /^[a-zA-Z]*\s×\s[a-zA-Z]*$/) ||
          (nomenclatural_code == :icn && name =~  /^[a-zA-Z]*\s×[a-zA-Z]*$/) ||
          (nomenclatural_code == :icn && name =~  /^×[a-zA-Z]*$/) ||
          (nomenclatural_code == :icvcn)
        correct_name_format = true
      end

      unless correct_name_format
        #invalid_statuses = TAXON_NAME_CLASS_NAMES_UNAVAILABLE_AND_INVALID
        #invalid_statuses = invalid_statuses & taxon_name_classifications.pluck(:type)
        #misspellings = TAXON_NAME_RELATIONSHIP_NAMES_MISSPELLING

        icvcn_species = (nomenclatural_code == :icvcn && self.rank_string =~ /Species/) ? true : nil
        #misspellings = misspellings & taxon_name_relationships.pluck(:type)
        if is_available? && icvcn_species.nil?
#          if invalid_statuses.empty? && misspellings.empty? && icvcn_species.nil?
          soft_validations.add(:name, 'Name should not have spaces or special characters, unless it has a status of misspelling or original misspelling')
        end
      end
    end
  end

  # @proceps, this is not OK.
  def sv_missing_confidence_level # should be removed once the alternative solution is implemented. It is havily used now
    confidence_level_array = [93]
    confidence_level_array = confidence_level_array & ConfidenceLevel.where(project_id: self.project_id).pluck(:id)
    soft_validations.add(:base, 'Confidence level is missing') if !confidence_level_array.empty? && (self.confidences.pluck(:confidence_level_id) & confidence_level_array).empty?
  end

  def sv_missing_original_publication
    if true #!self.cached_misspelling && !self.name_is_misapplied?

      if self.source.nil?
        soft_validations.add(:base, 'Original publication is not selected')
      elsif self.origin_citation.try(:pages).blank?
        soft_validations.add(:base, 'Original citation pages are not recorded')
      elsif !self.source.pages.blank?
        matchdata1 = self.origin_citation.pages.match(/(\d+) ?[-–] ?(\d+)|(\d+)/)
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

  def sv_missing_author
    true # see Protonym
  end

  def sv_missing_year
    true # see Protonym
  end

  def sv_missing_etymology
    true # see Protonym
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

  def sv_parent_is_valid_name
    if !parent.nil? && parent.unavailable_or_invalid?
      soft_validations.add(:parent_id, 'Parent should be a valid taxon', fix: :sv_fix_parent_is_valid_name, success_message: 'Parent was updated')
    end
  end

  def sv_fix_parent_is_valid_name
    if self.parent.unavailable_or_invalid?
      new_parent = self.parent.get_valid_taxon_name
      if self.parent != new_parent
        self.parent = new_parent
        if self.parent.rank_class.parent.to_s == 'NomenclaturalRank::Iczn::GenusGroup' && self.rank_class.to_s == 'NomenclaturalRank::Iczn::SpeciesGroup::Subspecies'
          self.rank_class = 'NomenclaturalRank::Iczn::SpeciesGroup::Species'
        elsif self.parent.rank_class.parent.to_s == 'NomenclaturalRank::Iczn::FamilyGroup' && self.rank_class.to_s == 'NomenclaturalRank::Iczn::GenusGroup::Subgenus'
          self.rank_class = 'NomenclaturalRank::Iczn::GenusGroup::Genus'
        end
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

  def sv_conflicting_subordinate_taxa
    classifications = self.taxon_name_classifications.reload
    classification_names = classifications.map { |i| i.type_name }
    compare = TAXON_NAME_CLASS_NAMES_UNAVAILABLE_AND_INVALID & classification_names
    unless compare.empty?
      unless Protonym.with_parent_taxon_name(self).without_taxon_name_classification_array(TAXON_NAME_CLASS_NAMES_UNAVAILABLE_AND_INVALID).empty?
        compare.each do |i|
          # taxon is unavailable or invalid, but has valid children
          soft_validations.add(:base, "Taxon has a status ('#{i.demodulize.underscore.humanize.downcase}') conflicting with presence of subordinate taxa")
        end
      end
    end
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
      soft_validations.add(:base, "Taxon has two conflicting relationships (invalidating and validating). To resolve a conflict, add a status 'Valid' to a valid taxon.")
    end
  end

  def sv_two_unresolved_alternative_synonyms
    r = taxon_name_relationships.includes(:source).order_by_oldest_source_first.with_type_array(TAXON_NAME_RELATIONSHIP_NAMES_SYNONYM)
    if r.to_a.size > 1
      if r.first.nomenclature_date.to_date == r.second.nomenclature_date.to_date
        soft_validations.add(:base, 'Taxon has two alternative invalidating relationships with identical dates. To resolve ambiguity, add original sources to the relationships with different priority dates.')
      end
    end
  end

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
