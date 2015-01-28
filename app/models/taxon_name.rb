# A taxonomic name (nomenclature only). 
#
# @!attribute year_of_publication 
#   @return [Integer]
#     the 4 digit year when this name was published! @proceps- clarify vs. made available.  ? = Source.year?
#
# @!attribute source_id 
#   @return [Integer]
#     the ID of the source (a Source::Bibtex or Source::Verbatim instance) in which this name was first published.  Subsequent references are made in citations or combinations. 
#
# @!attribute lft 
#   @return [Integer]
#     per awesome_nested_set. 
#
# @!attribute rgt 
#   @return [Integer]
#     per awesome_nested_set. 
#
# @!attribute parent_id
#   @return [Integer]
#     The id of the parent taxon. The parent child relationship is exclusively organizational. All statuses and relationships
#     of a taxon name must be explicitly defined via taxon name relatinoships or classifications. The parent of a taxon name 
#     can be thought of the "place where you'd find this name in a hierarchy if you knew literally *nothing* else about that name." 
#     In practice read each monomial in the name (protonym or combination) from right to left, the parent is the parent of the last monomial read.
#     There are 3 simple rules for determening the parent of a Protonym or Combination:
#       1) the parent must always be at least one rank higher than the target names rank
#       2) the parent of a synonym (any sense) is the parent of the synonym's valid name
#       3) the parent of a combination is the parent of the highest ranked monomial in the epithet (almost always the parent of the genus)
#
# @!attribute verbatim_author 
#   @return [String]
#     the verbatim author string as provided ? is not post-filled in when Source is referenced !?
#
# @!attribute cached
#   @return [String]
#    Genus-species combination for genus and lower, monomial for higher. The string has NO html.
#
# @!attribute cached_html
#   @return [String]
#     Genus-species combination for the taxon. The string is in html format including <em></em> tags.
#
# @attribute cached_author_year
#   @return [String]
#     author and year string with parentheses where necessarily.
#
# @!attribute cached_higher_classification
#   @return [String]
#     a concatenated list of higher rank taxa.
#
# @!attribute cached_original_combination
#   @return [String]
#     name as formed in original combination.
#
# @!attribute cached_classified_as
#   @return [String]
#     if the name was classified in different group (e.g. a genus placed in wrong family). 
#
# @attribute cached_primary_homonym
#   @return [String]
#     original genus and species name. Used to find and validate primary homonyms.
#
# @!attribute cached_secondary_homonym
#   @return [String]
#     current genus and species name. Used to find and validate secondary homonyms.
#
# @!attribute cached_primary_homonym_alternative_spelling
#   @return [String]
#   Original genus and species name in alternative spelling. Used to find and validate primary homonyms.
#
# @attribute cached_secondary_homonym_alternative_spelling
#   @return [String]
#   Current genus and species name in alternative spelling. Used to find and validate secondary homonyms.
#
# @attribute masculine_name, feminine_name, neuter_name
#   @return [String]
#     Species name which are adjective or participle change depending on the gender of the genus.
#     3 fields provide alternative species spelling. The part_of_speech designated as a taxon_name_classification.
#     The gender of the genus also designated as a taxon_name_classification.
#
# @attribute name_with_alternative_spelling
#   @return [String]
#   Alternative spelling of the name according to rules of homonymy.
#
#
class TaxonName < ActiveRecord::Base

  include Housekeeping
  include Shared::Citable
  include Shared::DataAttributes
  include Shared::Identifiable
  include Shared::Notable
  include Shared::IsData
  include SoftValidation

  acts_as_nested_set scope: [:project_id], dependent: :restrict_with_exception, touch: false

  before_validation :set_type_if_empty
  before_save :set_cached_names

  validate :check_format_of_name,
    :validate_rank_class_class,
    :validate_parent_rank_is_higher,
    :validate_parent_is_set,
    :check_new_rank_class,
    :check_new_parent_class,
    :validate_source_type,
    :validate_one_root_per_project

  belongs_to :source

  has_one :source_classified_as_relationship, -> {
    where(taxon_name_relationships: {type: 'TaxonNameRelationship::SourceClassifiedAs'} ) 
  }, class_name: 'TaxonNameRelationship::SourceClassifiedAs', foreign_key: :subject_taxon_name_id

  has_one :source_classified_as, through: :source_classified_as_relationship, source: :object_taxon_name # source_classified_as_taxon_name

  has_many :otus, inverse_of: :taxon_name, dependent: :nullify # :restrict_with_error ?
  has_many :related_taxon_name_relationships, class_name: 'TaxonNameRelationship', foreign_key: :object_taxon_name_id, dependent: :destroy
  has_many :taxon_name_author_roles, class_name: 'TaxonNameAuthor', as: :role_object, dependent: :destroy
  has_many :taxon_name_authors, through: :taxon_name_author_roles, source: :person
  has_many :taxon_name_classifications, dependent: :destroy, foreign_key: :taxon_name_id
  has_many :taxon_name_relationships, foreign_key: :subject_taxon_name_id, dependent: :destroy
  
  # NOTE: Protonym subclassed methods might not be nicely tracked here, we'll have to see.  Placement is after has_many relationships. (?)
  has_paper_trail

  accepts_nested_attributes_for :related_taxon_name_relationships, allow_destroy: true, reject_if: proc { |attributes| attributes['type'].blank? || attributes['subject_taxon_name_id'].blank? }

  scope :ordered_by_rank, -> { order(:lft) } # TODO: test
  scope :with_rank_class, -> (rank_class_name) { where(rank_class: rank_class_name) }
  scope :with_parent_taxon_name, -> (parent) { where(parent_id: parent) }
  scope :with_base_of_rank_class, -> (rank_class) { where('rank_class LIKE ?', "#{rank_class}%") }
  scope :with_rank_class_including, -> (include_string) { where('rank_class LIKE ?', "%#{include_string}%") }
  scope :descendants_of, -> (taxon_name) { where('(taxon_names.lft >= ?) and (taxon_names.lft <= ?) and (taxon_names.id != ?) and (taxon_names.project_id = ?)', taxon_name.lft, taxon_name.rgt, taxon_name.id, taxon_name.project_id) }
  scope :ancestors_of, -> (taxon_name) { where('(taxon_names.lft <= ?) and (taxon_names.rgt >= ?) and (taxon_names.id != ?) and (taxon_names.project_id = ?)', taxon_name.lft, taxon_name.rgt, taxon_name.id, taxon_name.project_id) }
  scope :ancestors_and_descendants_of, -> (taxon_name) {
    where('(((taxon_names.lft >= ?) AND (taxon_names.lft <= ?)) OR
           ((taxon_names.lft <= ?) AND (taxon_names.rgt >= ?))) AND
           (taxon_names.id != ?) AND (taxon_names.project_id = ?)',
           taxon_name.lft, taxon_name.rgt, taxon_name.lft, taxon_name.rgt, taxon_name.id, taxon_name.project_id) }

  # A specific relationship
  scope :as_subject_with_taxon_name_relationship, -> (taxon_name_relationship) { includes(:taxon_name_relationships).where(taxon_name_relationships: {type: taxon_name_relationship}) }
  scope :as_subject_with_taxon_name_relationship_base, -> (taxon_name_relationship) { includes(:taxon_name_relationships).where('taxon_name_relationships.type LIKE ?', "#{taxon_name_relationship}%").references(:taxon_name_relationships) }
  scope :as_subject_without_taxon_name_relationship_base, -> (taxon_name_relationship) { includes(:taxon_name_relationships).where('(taxon_name_relationships.type NOT LIKE ?) OR (taxon_name_relationships.subject_taxon_name_id IS NULL)', "#{taxon_name_relationship}%").references(:taxon_name_relationships) }
  scope :as_subject_with_taxon_name_relationship_containing, -> (taxon_name_relationship) { includes(:taxon_name_relationships).where('taxon_name_relationships.type LIKE ?', "%#{taxon_name_relationship}%").references(:taxon_name_relationships) }
  scope :as_object_with_taxon_name_relationship, -> (taxon_name_relationship) { includes(:related_taxon_name_relationships).where(taxon_name_relationships: {type: taxon_name_relationship}) }
  scope :as_object_with_taxon_name_relationship_base, -> (taxon_name_relationship) { includes(:related_taxon_name_relationships).where('taxon_name_relationships.type LIKE ?', "#{taxon_name_relationship}%").references(:related_taxon_name_relationships) }
  scope :as_object_with_taxon_name_relationship_containing, -> (taxon_name_relationship) { includes(:related_taxon_name_relationships).where('taxon_name_relationships.type LIKE ?', "%#{taxon_name_relationship}%").references(:related_taxon_name_relationships) }
  scope :with_taxon_name_relationship, -> (relationship) {
    joins('LEFT OUTER JOIN taxon_name_relationships tnr1 ON taxon_names.id = tnr1.subject_taxon_name_id').
      joins('LEFT OUTER JOIN taxon_name_relationships tnr2 ON taxon_names.id = tnr2.object_taxon_name_id').
      where('tnr1.type = ? OR tnr2.type = ?', relationship, relationship)
  }

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

  # TODO move to shared code (Shared::IsData)
  scope :not_self, -> (id) {where('taxon_names.id <> ?', id )}


  scope :with_parent_id, -> (parent_id) {where(parent_id: parent_id)}

  validates_presence_of :type, message: 'Type is not specified'
  validates_presence_of :rank_class, message: 'Rank is a required field', if: Proc.new { |tn| [Protonym].include?(tn.class) }
  validates_presence_of :name, message: 'Name is a required field', if: Proc.new { |tn| [Protonym].include?(tn.class) }

  soft_validate(:sv_validate_name, set: :validate_name)
  soft_validate(:sv_missing_fields, set: :missing_fields)
  soft_validate(:sv_parent_is_valid_name, set: :parent_is_valid_name)
  soft_validate(:sv_cached_names, set: :cached_names)

  # @return array of relationships
  #   all relationships where this taxon is an object or subject.
  def all_taxon_name_relationships
    # !! If self relatinships are every made possible this needs a DISTINCT clause
    TaxonNameRelationship.find_by_sql("SELECT taxon_name_relationships.* FROM taxon_name_relationships WHERE taxon_name_relationships.subject_taxon_name_id = #{self.id} UNION
                         SELECT taxon_name_relationships.* FROM taxon_name_relationships WHERE taxon_name_relationships.object_taxon_name_id = #{self.id}")
  end

  # @return [Array of TaxonName]
  #     all taxon_names which have relationships to this taxon as an object or subject.
  def related_taxon_names
    TaxonName.find_by_sql("SELECT DISTINCT tn.* FROM taxon_names tn
                      LEFT JOIN taxon_name_relationships tnr1 ON tn.id = tnr1.subject_taxon_name_id
                      LEFT JOIN taxon_name_relationships tnr2 ON tn.id = tnr2.object_taxon_name_id
                      WHERE tnr1.object_taxon_name_id = #{self.id} OR tnr2.subject_taxon_name_id = #{self.id};")
  end
  
  # @return [String]
  #   rank as human readable shortform, like 'genus' or 'species'
  def rank
    ::RANKS.include?(self.rank_string) ? self.rank_class.rank_name : nil
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

  # This is the baseline means of displaying taxon name authorship. 
  # @return
  #   the author for this taxon, last name only
  def author_string
    if !self.verbatim_author.nil?
      self.verbatim_author
    elsif !self.source_id.nil?
      self.source.authority_name
    else
      nil
    end
  end

  # TODO: rename to reflect returning of string
  # @return [String]
  #   a 4 digit string representing year of publication, like '1974'
  def year_integer
    return self.year_of_publication if !self.year_of_publication.nil?
    return self.source.year if !self.source_id.nil?
    nil
  end

  # Used to determine nomenclatural priorities
  # @return [Time]
  #   effective date of publication.
  def nomenclature_date
    return nil if self.id.nil?
    family_before_1961 = TaxonNameRelationship.where_subject_is_taxon_name(self).with_type_string('TaxonNameRelationship::Iczn::PotentiallyValidating::FamilyBefore1961').first
    if family_before_1961.nil?
      year = self.year_of_publication ? Time.utc(self.year_of_publication, 12, 31) : nil
      self.source ? (self.source.cached_nomenclature_date ? self.source.cached_nomenclature_date.to_time : year) : year
    else
      obj  = family_before_1961.object_taxon_name
      year = obj.year_of_publication ? Time.utc(obj.year_of_publication, 12, 31) : nil
      obj.source ? (self.source.cached_nomenclature_date ? obj.source.cached_nomenclature_date.to_time : year) : year
    end
  end

  # @return [Class]
  #   gender of a genus as class
  def gender_class
    c = TaxonNameClassification.where_taxon_name(self).with_type_base('TaxonNameClassification::Latinized::Gender').first
    c.nil? ? nil : c.type_class
  end

  # @return [String]
  #   gender of a genus as string.
  def gender_name
    c = self.gender_class
    c.nil? ? nil : c.class_name
  end

  # @return [Class]
  #   part of speech of a species as class.
  def part_of_speech_class
    c = TaxonNameClassification.where_taxon_name(self).with_type_base('TaxonNameClassification::Latinized::PartOfSpeech').first
    c.nil? ? nil : c.type_class
  end

  # @return [String]
  #   part of speech of a species as string.
  def part_of_speech_name
    c = self.part_of_speech_class
    c.nil? ? nil : c.class_name
  end

  # @return [String]
  #   combination of cached_html and cached_author_year.
  def cached_name_and_author_year
    if self.rank_string =~ /::(Species|Genus)/
      (self.cached_html.to_s + ' ' + self.cached_author_year.to_s).squish!
    else
      (self.name.to_s + ' ' + self.cached_author_year.to_s).squish!
    end
  end
  
  # @return [TaxonName | nil] an ancestor at the specified rank
  def ancestor_at_rank(rank)
    TaxonName.ancestors_of(self).with_rank_class(Ranks.lookup(self.rank_class.nomenclatural_code, rank)).first
  end

  # @return [Array of TaxonName] ancestors of type 'Protonym'
  def ancestor_protonyms
    TaxonName.ancestors_of(self).where(type: 'Protonym')
  end

# @return [Array of TaxonName] descendants of type 'Protonym'
  def descendant_protonyms
    TaxonName.descendants_of(self).where(type: 'Protonym')
  end

  # TODO: @proceps - based on what?
  # @return [True|False]
  def unavailable_or_invalid?
    if self.rank_class
      case self.rank_class.nomenclatural_code
      when :iczn
        if !TaxonNameRelationship::Iczn::Invalidating.where_subject_is_taxon_name(self).empty? || !TaxonNameClassification.where_taxon_name(self).with_type_array(TAXON_NAME_CLASS_NAMES_UNAVAILABLE_AND_INVALID).empty?
          return true
        end
      when :icz
        if !TaxonNameRelationship::Icn::Unaccepting.where_subject_is_taxon_name(self).empty? || !TaxonNameClassification.where_taxon_name(self).with_type_array(TAXON_NAME_CLASS_NAMES_UNAVAILABLE_AND_INVALID).empty?
          return true
        end
      end
    end
    return false
  end

  # @return [True|False]
  def unavailable?
    if !TaxonNameClassification.where_taxon_name(self).with_type_array(TAXON_NAME_CLASS_NAMES_UNAVAILABLE_AND_INVALID).empty?
      true
    else
      false
    end
  end

  # @return [TaxonName]
  #   a valid taxon_name for an invalid name or self for valid name.
  def get_valid_taxon_name 
    vn = TaxonNameRelationship.where_subject_is_taxon_name(self).with_type_array(TAXON_NAME_RELATIONSHIP_NAMES_INVALID)
    (vn.count == 1) ? vn.first.object_taxon_name : self
  end

  def gbif_status_array
    return nil if self.class.nil?
    return ['combinatio'] if self.class == 'Combination'
    s1 = self.taxon_name_classifications.collect{|c| c.class.gbif_status}.compact
    return s1 unless s1.empty?
    s2 = self.taxon_name_relationships.collect{|r| r.class.gbif_status_of_subject}
    s3 = self.related_taxon_name_relationships.collect{|r| r.class.gbif_status_of_object}

    s = s2 + s3
    s.compact!
    return ['valid'] if s.empty?
    s
  end

  def name_with_alternative_spelling
    if self.class != Protonym || self.rank_class.nil? || self.rank_class.to_s =~ /::Icn::/
      return nil
    elsif self.rank_string =~ /Species/
      n = self.name.squish # remove extra spaces and line brakes
      n = n.split(' ').last
      n = n[0..-4] + 'ae' if n =~ /^[a-z]*iae$/ # -iae > -ae in the end of word
      n = n[0..-6] + 'orum' if n =~ /^[a-z]*iorum$/ # -iorum > -orum
      n = n[0..-6] + 'arum' if n =~ /^[a-z]*iarum$/ # -iarum > -arum
      n = n[0..-3] + 'a' if n =~ /^[a-z]*um$/ # -um > -a
      n = n[0..-3] + 'a' if n =~ /^[a-z]*us$/ # -us > -a
      n = n[0..-3] + 'ra' if n =~ /^[a-z]*er$/ # -er > -ra
      n = n[0..-7] + 'ensis' if n =~ /^[a-z]*iensis$/ # -iensis > -ensis
      n = n[0..-5] + 'ana' if n =~ /^[a-z]*iana$/ # -iana > -ana
      n = n.gsub('ae', 'e').
        gsub('oe', 'e').
        gsub('ai', 'i').
        gsub('ei', 'i').
        gsub('ej', 'i').
        gsub('ii', 'i').
        gsub('ij', 'i').
        gsub('jj', 'i').
        gsub('j', 'i').
        gsub('y', 'i').
        gsub('v', 'u').
        gsub('rh', 'r').
        gsub('th', 't').
        gsub('k', 'c').
        gsub('ch', 'c').
        gsub('tt', 't').
        gsub('bb', 'b').
        gsub('rr', 'r').
        gsub('nn', 'n').
        gsub('mm', 'm').
        gsub('pp', 'p').
        gsub('ss', 's').
        gsub('ff', 'f').
        gsub('ll', 'l').
        gsub('ct', 't').
        gsub('ph', 'f').
        gsub('-', '')
      n = n[0, 3] + n[3..-4].gsub('o', 'i') + n[-3, 3] if n.length > 6 # connecting vowel in the middle of the word (nigrocinctus vs. nigricinctus)
    elsif self.rank_string =~ /Family/
      n_base = Protonym.family_group_base(self.name)
      if n_base.nil?
        n = self.name
      else
        n = n_base + 'idae'
      end
    else
      n = self.name.squish
    end
    return n
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
    n.blank? ? self.name : n
  end

  #region Set cached fields

  def set_type_if_empty
    self.type = 'Protonym' if self.type.nil?
  end

  def set_cached_names
    if self.errors.empty?
      set_cached

      # if updated, update also sv_cached_names
      set_cached_html
      set_cached_author_year
      set_cached_classified_as

      # @proceps this line does nothing:
      #self.cached_original_combination.blank? if self.class == Protonym

      # @proceps - move this to Combination
      set_cached_original_combination
    end
  end

  # override in subclasses
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
    misspelling = TaxonName.as_subject_with_taxon_name_relationship_containing('::Usage::Misspelling')
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
      self.self_and_ancestors
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
  # @taxon_name.full_name_hash # => {"genus"=>[nil, "Aus"], "subgenus"=>[nil, "Aus"], "section"=>["sect.", "Aus"], "series"=>["ser.", "Aus"], "species"=>[nil, "aaa"], "subspecies"=>[nil, "bbb"], "variety"=>["var.", "ccc"]}
  def full_name_hash
    gender = nil
    data   = {}
    safe_self_and_ancestors.each do |i| # !! You can not use self.self_and_ancesotrs because (this) record is not saved off.
      rank   = i.rank
      gender = i.gender_name if rank == 'genus'
      method = "#{rank.gsub(/\s/, '_')}_name_elements"
      data.merge!(rank => send(method, i, gender)) if self.respond_to?(method)
    end
    data
  end

  # @return [String]
  #  a monomial if names is above genus, or a full epithet if below. 
  # TODO: rename to get_full_name (when name is available)
  def get_full_name_no_html
    return name unless GENUS_AND_SPECIES_RANK_NAMES.include?(self.rank_string) || self.type == 'Combination'
    d        = full_name_hash
    elements = []
    elements.push(d['genus'])
    elements.push ['(', d['subgenus'], d['section'], d['subsection'], d['series'], d['subseries'], ')']
    elements.push ['(', d['superspecies'], ')']
    elements.push(d['species'], d['subspecies'], d['variety'], d['subvariety'], d['form'], d['subform'])
    elements.flatten.compact.join(" ").gsub(/\(\s*\)/, '').gsub(/\(\s/, '(').gsub(/\s\)/, ')').squish
  end


  # TODO: rename to get_full_name_html
  # @return [String]
  #  a monomial if names is above genus, or a full epithet if below, includes html
  def get_full_name
    return nil unless GENUS_AND_SPECIES_RANK_NAMES.include?(self.rank_string) || self.type == 'Combination'
    d        = full_name_hash
    elements = []
    eo       = '<em>'
    ec       = '</em>'
    d.merge!('genus' => [nil, '[GENUS NOT PROVIDED]']) if !d['genus']

    elements.push("#{eo}#{d['genus'][1]}#{ec}")
    elements.push ['(', %w{subgenus section subsection series subseries}.collect { |r| d[r] ? [d[r][0], "#{eo}#{d[r][1]}#{ec}"] : nil }, ')']
    elements.push ['(', eo, d['superspecies'], ec, ')'] if d['superspecies']

    %w{species subspecies variety subvariety form subform}.each do |r|
      elements.push(d[r][0], "#{eo}#{d[r][1]}#{ec}") if d[r]
    end

    elements.flatten.compact.join(" ").gsub(/\(\s*\)/, '').gsub(/\(\s/, '(').gsub(/\s\)/, ')').squish.gsub('</em> <em>', ' ')
  end

  def genus_name_elements(*args)
    [nil, args[0].name]
  end

  def subgenus_name_elements(*args)
    [nil, args[0].name]
  end

  def section_name_elements(*args)
    ['sect.', args[0].name]
  end

  def subsection_name_elements(*args)
    ['subsect.', args[0].name]
  end

  def series_name_elements(*args)
    ['ser.', args[0].name]
  end

  def subseries_name_elements(*args)
    ['subser.', args[0].name]
  end

  def species_group_name_elements(*args)
    [nil, args[0].name_in_gender(args[1])]
  end

  def species_name_elements(*args)
    [nil, args[0].name_in_gender(args[1])]
  end

  def subspecies_name_elements(*args)
    [nil, args[0].name_in_gender(args[1])]
  end

  def variety_name_elements(*args)
    ['var.', args[0].name_in_gender(args[1])]
  end

  def subvariety_name_elements(*args)
    ['subvar.', args[0].name_in_gender(args[1])]
  end

  def form_name_elements(*args)
    ['form', args[0].name_in_gender(args[1])]
  end

  def subform_name_elements(*args)
    ['subform', args[0].name_in_gender(args[1])]
  end

  def name_with_misspelling(gender)
    if self.cached_misspelling
      self.name.to_s + ' [sic]'
    elsif gender.nil? || self.rank_string =~ /Genus/
      self.name.to_s
    else
      self.name_in_gender(gender)
    end
  end

  # TODO: refactor to use us a hash!
  # Returns a String representing the name as originally published
  def get_original_combination
    unless GENUS_AND_SPECIES_RANK_NAMES.include?(self.rank_string) && self.class == Protonym
      cached_html = nil
    else
      relationships = self.original_combination_relationships
      relationships = relationships.sort_by{|r| r.type_class.order_index }
      genus         = ''
      subgenus      = ''
      superspecies  = ''
      species       = ''
      gender        = nil
      relationships.each do |i|
        case i.type_class.object_relationship_name
          when 'original genus'
            genus  = '<em>' + i.subject_taxon_name.name_with_misspelling(nil) + '</em> '
            gender = i.subject_taxon_name.gender_name
          when 'original subgenus' 
            subgenus += '<em>' + i.subject_taxon_name.name_with_misspelling(nil) + '</em> '
          when 'original section' 
            subgenus += 'sect. <em>' + i.subject_taxon_name.name_with_misspelling(nil) + '</em> '
          when 'original subsection' 
            subgenus += 'subsect. <em>' + i.subject_taxon_name.name_with_misspelling(nil) + '</em> '
          when 'original series' 
            subgenus += 'ser. <em>' + i.subject_taxon_name.name_with_misspelling(nil) + '</em> '
          when 'original subseries' 
            subgenus += 'subser. <em>' + i.subject_taxon_name.name_with_misspelling(nil) + '</em> '
          when 'original species' 
            species += '<em>' + i.subject_taxon_name.name_with_misspelling(gender) + '</em> '
          when 'original subspecies' 
            species += '<em>' + i.subject_taxon_name.name_with_misspelling(gender) + '</em> '
          when 'original variety' 
            species += 'var. <em>' + i.subject_taxon_name.name_with_misspelling(gender) + '</em> '
          when 'original subvariety' 
            species += 'subvar. <em>' + i.subject_taxon_name.name_with_misspelling(gender) + '</em> '
          when 'original form' 
            species += 'f. <em>' + i.subject_taxon_name.name_with_misspelling(gender) + '</em> '
        end
      end
      if self.rank_string =~ /Genus/
        if genus.blank?
          genus += '<em>' + self.name_with_misspelling(nil) + '</em> '
        else
          subgenus += '<em>' + self.name_with_misspelling(nil) + '</em> '
        end
      elsif self.rank_string =~ /Species/
        species += '<em>' + self.name_with_misspelling(nil) + '</em> '
        genus   = '<em>' + self.ancestor_at_rank('genus').name_with_misspelling(nil) + '</em> ' if genus.empty? && !self.ancestor_at_rank('genus').nil?
      end
      subgenus    = '(' + subgenus.squish + ') ' unless subgenus.empty?
      cached_html = (genus + subgenus + superspecies + species).squish.gsub('</em> <em>', ' ')
      cached_html.blank? ? nil : cached_html
    end
  end

  def get_genus_species(genus_option, self_option)
    genus = nil
    name1 = nil
    return nil if self.rank_class.nil?

    if genus_option == :original
      genus = self.original_genus
    elsif genus_option == :current
      genus = self.ancestor_at_rank('genus')
    end
    genus = genus.name unless genus.blank?

    return nil if self.rank_string =~ /Species/ && genus.blank?
    if self_option == :self
      name1 = self.name
    elsif self_option == :alternative
      name1 = self.name_with_alternative_spelling
    end
    (genus.to_s + ' ' + name1.to_s).squish
  end

  # Returns a String with the author and year of the name. Adds parenthesis.
  #
  def get_author_and_year
    return ([self.author_string] + [self.year_integer]).compact.join(', ') if self.rank.nil?
    rank = self.rank_class

    if rank.nomenclatural_code == :iczn
      misapplication = TaxonNameRelationship.where_subject_is_taxon_name(self).
        with_type_string('TaxonNameRelationship::Iczn::Invalidating::Usage::Misapplication')
      a = [self.author_string]

      if a[0] =~ /^\(.+\)$/ # (Author)
        a[0] = a[0][1..-2]
        p = true
      else
        p = false
      end

      ay = (a + [self.year_integer]).compact.join(', ')
      obj = misapplication.empty? ? nil : misapplication.first.object_taxon_name

      unless (misapplication.empty? || obj.author_string.blank?)
        ay += ' nec ' + ([obj.author_string] + [obj.year_integer]).compact.join(', ')
      end

      if SPECIES_RANK_NAMES_ICZN.include?(rank.to_s)
        if p
          ay = '(' + ay + ')' unless ay.empty?
        else
          og = self.original_genus
          cg = self.ancestor_at_rank('genus')
          unless og.nil? || cg.nil?
            ay = '(' + ay + ')' unless ay.empty? if og.name != cg.name
          end
        #((self.original_genus.name != self.ancestor_at_rank('genus').name) && !self.original_genus.name.to_s.empty?)
        end
      end

    elsif rank.nomenclatural_code == :icn
      basionym = TaxonNameRelationship.where_object_is_taxon_name(self).
          with_type_string('TaxonNameRelationship::Icn::Unaccepting::Usage::Basionym')
      misapplication = TaxonNameRelationship.where_subject_is_taxon_name(self).
          with_type_string('TaxonNameRelationship::Icn::Unaccepting::Usage::Misapplication')
      b_sub = basionym.empty? ? nil : basionym.first.subject_taxon_name
      m_obj = misapplication.empty? ? nil : misapplication.first.object_taxon_name


      t  = [self.author_string]
      t  += ['(' + self.year_integer.to_s + ')'] unless self.year_integer.nil?
      ay = t.compact.join(' ')

      unless (basionym.empty? || b_sub.author_string.blank?)
        ay = '(' + b_sub.author_string + ') ' + ay
      end
      unless (misapplication.empty? || m_obj.author_string.blank?)
        ay += ' nec ' + [m_obj.author_string]
        t  += ['(' + m_obj.year_integer.to_s + ')'] unless m_obj.year_integer.nil?
      end
    else
      ay = ([self.author_string] + [self.year_integer]).compact.join(' ')
    end
    ay
  end

  def get_higher_classification
    # see config/initializers/ranks for FAMILY_AND_ABOVE_RANK_NAMES
    safe_self_and_ancestors.select { |i| FAMILY_AND_ABOVE_RANK_NAMES.include?(i.rank_string) }.collect { |i| i.name }.join(':')
  end

  def get_cached_classified_as
    # note defined for Protonym
    unless self.type == 'Combination' || self.type == 'Protonym'
      return nil
    end

    if c = self.source_classified_as
      " (as #{c.name})" 
    else
      nil
    end
  end

  def self.find_for_autocomplete(params)
    t = params[:term]
    limit = 10 
    case t.length
    when 0..3
    else
      limit = 20
    end
    
    where('(cached  ~~* ?) OR (name  ~~* ?)', t, t).with_project_id(params[:project_id]).limit(limit).order(:name, :cached)
  end

  # A proxy for a scope
  # @return [Array of TaxonName] 
  #   ordered by rank
  def self.sort_by_rank(taxon_names)
    taxon_names.sort!{|a,b| RANKS.index(a.rank_string) <=> RANKS.index(b.rank_string)} 
  end

  #endregion

  protected

  #region Validation

  def validate_parent_is_set
    if !(self.rank_class == NomenclaturalRank) && !(self.type == 'Combination')
      errors.add(:parent_id, 'A parent is not selected') if self.parent_id.blank?
    end
  end

  def check_format_of_name
    if self.rank_class && self.rank_class.respond_to?(:validate_name_format)
      self.rank_class.validate_name_format(self)
    end
  end

  def validate_parent_rank_is_higher
    if self.parent && !self.rank_class.blank? && self.rank_string != 'NomenclaturalRank'
      if RANKS.index(self.rank_string) <= RANKS.index(self.parent.rank_string)
        errors.add(:parent_id, "The parent rank (#{self.parent.rank_class.rank_name}) is not higher than #{self.rank_class.rank_name}")
      end

      if (self.rank_class != self.rank_class_was) && # @proceps this catches nothing, as self.rank_class_was is never defined!
        self.children &&
        !self.children.empty? &&
        RANKS.index(self.rank_string) >= self.children.collect { |r| RANKS.index(r.rank_string) }.max
        errors.add(:rank_class, "The taxon rank (#{self.rank_class.rank_name}) is not higher than child ranks")
      end
    end
  end

  def validate_rank_class_class
    if self.type == 'Combination'
      errors.add(:rank_class, 'Combination should not have rank') if !!self.rank_class
    elsif self.type == 'Protonym'
      errors.add(:rank_class, 'Rank not found') unless Ranks.valid?(rank_class)
    end
  end

  # @proceps self.rank_class_was is not a class method anywhere, so this comparison is vs. nil
  # @mjy: self.rank_class_was returns old value from the database before replacing it with a new value on update.
  def check_new_rank_class
    if (self.rank_class != self.rank_class_was) && !self.rank_class_was.nil?
      old_rank_group = self.rank_class_was.safe_constantize.parent
      if self.rank_class.parent != old_rank_group
        errors.add(:rank_class, "A new taxon rank (#{self.rank_class.rank_name}) should be in the #{old_rank_group.rank_name}")
      end
    end
  end

  def check_new_parent_class
    if self.parent_id != self.parent_id_was && !self.parent_id_was.nil? && self.rank_class.nomenclatural_code == :iczn
      old_parent = TaxonName.find_by_id(self.parent_id_was)
      if (self.rank_class.rank_name == 'subgenus' || self.rank_class.rank_name == 'subspecies') && old_parent.name == self.name
        errors.add(:parent_id, "The nominotypical #{self.rank_class.rank_name} #{self.name} could not be moved out of the nominal #{old_parent.rank_class.rank_name}")
      end
    end
  end

  def validate_source_type
    errors.add(:source_id, 'Source must be a Bibtex') if self.source && self.source.type != 'Source::Bibtex'
  end

  def validate_one_root_per_project
    if new_record? || project_id_changed?
      errors.add(:parent_id, 'Only one root allowed per project') if parent_id.nil? && TaxonName.where(parent_id: nil, project_id: self.project_id).count > 0
    end 
  end

  #TODO: validate, that all the ranks in the table could be linked to ranks in classes (if those had changed)

  #endregion

  #region Soft validation

  def sv_validate_name
    correct_name_format = false

    if self.rank_class
      # TODO: name these Regexp somewhere
      if (self.name =~ /^[a-zA-Z]*$/) ||
          (self.rank_class.nomenclatural_code == :iczn && self.name =~ /^[a-zA-Z]-[a-zA-Z]*$/) ||
          (self.rank_class.nomenclatural_code == :icn && self.name =~ /^[a-zA-Z]*-[a-zA-Z]*$/) ||
          (self.rank_class.nomenclatural_code == :icn && self.name =~ /^[a-zA-Z]*\s×\s[a-zA-Z]*$/) ||
          (self.rank_class.nomenclatural_code == :icn && self.name =~ /^×\s[a-zA-Z]*$/)
        correct_name_format = true
      end

      unless correct_name_format
        invalid_statuses = TAXON_NAME_CLASS_NAMES_UNAVAILABLE_AND_INVALID
        invalid_statuses = invalid_statuses & self.taxon_name_classifications.collect { |c| c.type_class.to_s }
        misspellings     = TaxonNameRelationship.collect_to_s(
          TaxonNameRelationship::Iczn::Invalidating::Usage::IncorrectOriginalSpelling,
          TaxonNameRelationship::Iczn::Invalidating::Usage::Misspelling,
          TaxonNameRelationship::Icn::Unaccepting::Usage::Misspelling)
        misspellings     = misspellings & self.taxon_name_relationships.collect { |c| c.type_class.to_s }
        if invalid_statuses.empty? && misspellings.empty?
          soft_validations.add(:name, 'Name should not have spaces or special characters, unless it has a status of misspelling')
        end
      end
    end

    # TODO: break this one out   
    if SPECIES_RANK_NAMES.include?(self.rank_string)
      soft_validations.add(:name, 'name must be lower case') unless self.name == self.name.downcase
    end

  end

  def sv_missing_fields
    soft_validations.add(:source_id, 'Source is missing') if self.source_id.nil?
    soft_validations.add(:verbatim_author, 'Author is missing',
                         fix: :sv_fix_missing_author,
                         success_message: 'Author was updated') if self.verbatim_author.blank?
    soft_validations.add(:year_of_publication, 'Year is missing',
                         fix: :sv_fix_missing_year,
                         success_message: 'Year was updated') if self.year_of_publication.nil?
  end

  def sv_fix_missing_author
    if self.source_id
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
    if self.source_id
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
    return if parent.nil?
    if parent.unavailable_or_invalid?
      # parent of a taxon is unavailable or invalid
      soft_validations.add(:parent_id, 'Parent should be a valid taxon',
                           fix:             :sv_fix_parent_is_valid_name,
                           success_message: 'Parent was updated')
    else # TODO: This seems like a different validation, split with above?
      classifications      = self.taxon_name_classifications
      classification_names = classifications.map { |i| i.type_name }
      compare              = TAXON_NAME_CLASS_NAMES_UNAVAILABLE_AND_INVALID & classification_names
      unless compare.empty?
        unless Protonym.with_parent_taxon_name(self).without_taxon_name_classification_array(TAXON_NAME_CLASS_NAMES_UNAVAILABLE_AND_INVALID).empty?
          compare.each do |i|
            # taxon is unavailable or invalid, but has valid children
            soft_validations.add(:base, "Taxon has a status ('#{i.safe_constantize.class_name}') conflicting with presence of subordinate taxa")
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

  # @proceps: see comments in spec.  cached values should be set only after a record is valid, on before_save.
  # @mjy: cached values should be updated when related taxa change (new genus, or a new original genus). That what is done in this test

  def sv_cached_names
       # if updated, update also set_cached_names
       is_cached = true
       is_cached = false if self.cached_author_year != get_author_and_year

       if self.class == Protonym && cached # don't run the tests if it's already false
         if self.cached_html != get_full_name ||
           self.cached_misspelling != get_cached_misspelling ||
           self.cached_original_combination != get_original_combination ||
           self.cached_higher_classification != get_higher_classification ||
           self.cached_primary_homonym != get_genus_species(:original, :self) ||
           self.cached_primary_homonym_alternative_spelling != get_genus_species(:original, :alternative) ||
           self.rank_string =~ /Species/ && (self.cached_secondary_homonym != get_genus_species(:current, :self) || self.cached_secondary_homonym_alternative_spelling != get_genus_species(:current, :alternative))
           is_cached = false
         end
       end

     # Combination caching is handled in Combination
     # if self.class == Combination && cached
     #   if self.cached_html != get_combination || self.cached_original_combination != get_combination
     #     is_cached = false
     #   end
     # end

       soft_validations.add(
         :base, 'Cached values should be updated',
         fix: :sv_fix_cached_names, success_message: 'Cached values were updated'
       ) if !is_cached
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

  #endregion

end


