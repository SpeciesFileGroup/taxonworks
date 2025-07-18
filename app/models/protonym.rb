# Nested ness of this should get all the relationships?
# require_dependency Rails.root.to_s + '/app/models/taxon_name_relationship.rb'


# A *monomial* TaxonName, a record implies a first usage. This follows Pyle's concept almost exactly.
#
# We inject a lot of relationship helper methods here, in this format.
#   subject                      object
#   Aus      original_genus of   bus
#   aus      type_species of     Bus
#
class Protonym < TaxonName

  extend Protonym::SoftValidationExtensions::Klass
  include Protonym::SoftValidationExtensions::Instance
  include Protonym::Becomes
  include Protonym::Format

  # @return [Boolean]
  #   memoize `#is_avaiable?`
  # TODO: CACHED NOW
  # attr_reader :is_available

  # @return Hash
  #   !! Use only during building cached values. Idea
  #   !! is to store values used downstream in setting cached values.
  attr_reader :_cached_build_state

  alias_method :original_combination_source, :source

  FAMILY_GROUP_ENDINGS = %w{ini ina inae idae oidae odd ad oidea}.freeze

  validates_presence_of :name, message: 'is a required field'
  validates_presence_of :rank_class, message: 'is a required field'

  validate :validate_rank_class_class,
    :validate_same_nomenclatural_code,
    :validate_parent_rank_is_higher,
    :validate_child_rank_is_equal_or_lower,
    :check_new_rank_class,
    # :check_new_parent_class, # currently runs on taxon_name.rb
    :validate_source_type,
    :new_parent_taxon_name,
    :name_is_latinized,
    :name_is_valid_format,
    :verbatim_author_without_digits,
    :verbatim_author_with_closed_parens_when_present

  has_one :type_taxon_name_relationship, -> {
    where("taxon_name_relationships.type LIKE 'TaxonNameRelationship::Typification::%'")
  }, class_name: 'TaxonNameRelationship', foreign_key: :object_taxon_name_id

  has_one :type_taxon_name, through: :type_taxon_name_relationship, source: :subject_taxon_name

  has_one :latinized_taxon_name_classification, -> {
    where("taxon_name_classifications.type LIKE 'TaxonNameClassification::Latinized::%'")
  }, class_name: 'TaxonNameClassification', foreign_key: :taxon_name_id

  has_many :type_of_relationships, -> {
    where("taxon_name_relationships.type LIKE 'TaxonNameRelationship::Typification::%'")
  }, class_name: 'TaxonNameRelationship', foreign_key: :subject_taxon_name_id

  has_many :type_of_taxon_names, through: :type_of_relationships, source: :object_taxon_name

  has_many :original_combination_relationships, -> {
    where("taxon_name_relationships.type LIKE 'TaxonNameRelationship::OriginalCombination::%'")
  }, class_name: 'TaxonNameRelationship', foreign_key: :object_taxon_name_id

  has_many :original_combination_protonyms, through: :original_combination_relationships, source: :subject_taxon_name

  has_many :combination_relationships, -> {
    where("taxon_name_relationships.type LIKE 'TaxonNameRelationship::Combination::%'")
  }, class_name: 'TaxonNameRelationship', foreign_key: :subject_taxon_name_id

  has_many :combinations, through: :combination_relationships, source: :object_taxon_name
  has_many :type_materials, class_name: 'TypeMaterial', inverse_of: :protonym

  # Probably reference 'specified'
  scope :original_combination_unspecified, -> { where("taxon_names.cached_original_combination LIKE '%NOT SPECIFIED%'") }
  scope :original_combination_specified, -> { where("taxon_names.cached_original_combination IS NOT null AND taxon_names.cached_original_combination NOT LIKE '%NOT SPECIFIED%'") }

  # Dynamically define relations based the model metadata
  TaxonNameRelationship.descendants.each do |d|
    if d.respond_to?(:assignment_method)
      if d.name.to_s =~ /TaxonNameRelationship::(Iczn|Icn|Icvcn|Icnp|SourceClassifiedAs)/
        relationship = "#{d.assignment_method}_relationship".to_sym
        has_one relationship, class_name: d.name.to_s, foreign_key: :subject_taxon_name_id
        has_one d.assignment_method.to_sym, through: relationship, source: :object_taxon_name
      end

      if d.name.to_s =~ /TaxonNameRelationship::(OriginalCombination|Typification)/
        relationships = "#{d.assignment_method}_relationships".to_sym
        # ActiveRecord::Base.send(:sanitize_sql_array, [d.name])
        has_many relationships, -> {
          where('taxon_name_relationships.type LIKE ?', d.name + '%')
        }, class_name: 'TaxonNameRelationship', foreign_key: :subject_taxon_name_id
        has_many d.assignment_method.to_s.pluralize.to_sym, through: relationships, source: :object_taxon_name
      end
    end

    if d.respond_to?(:inverse_assignment_method)
      if d.name.to_s =~ /TaxonNameRelationship::(Iczn|Icn|Icnp|Icvcn|SourceClassifiedAs)/
        relationships = "#{d.inverse_assignment_method}_relationships".to_sym
        # ActiveRecord::Base.send(:sanitize_sql_array, [d.name])
        has_many relationships, -> {
          where('taxon_name_relationships.type LIKE ?', d.name + '%')
        }, class_name: 'TaxonNameRelationship', foreign_key: :object_taxon_name_id
        has_many d.inverse_assignment_method.to_s.pluralize.to_sym, through: relationships, source: :subject_taxon_name
      end

      if d.name.to_s =~ /TaxonNameRelationship::(OriginalCombination|Typification)/ # |SourceClassifiedAs
        relationship = "#{d.inverse_assignment_method}_relationship".to_sym
        has_one relationship, class_name: d.name.to_s, foreign_key: :object_taxon_name_id
        has_one d.inverse_assignment_method.to_sym, through: relationship, source: :subject_taxon_name
      end
    end
  end

  # TODO: remove
  scope :named, -> (name) {where(name:)}

  scope :with_name_in_array, -> (array) {where(name: array) }

  # find classifications for taxon
  scope :with_taxon_name_classifications_on_taxon_name, -> (t) { includes(:taxon_name_classifications).where('taxon_name_classifications.taxon_name_id = ?', t).references(:taxon_name_classifications) }

  # find taxa with classifications
  scope :with_taxon_name_classifications, -> { joins(:taxon_name_classifications) }
  scope :with_taxon_name_classification, -> (taxon_name_class_name) { includes(:taxon_name_classifications).where('taxon_name_classifications.type = ?', taxon_name_class_name).references(:taxon_name_classifications) }
  scope :with_taxon_name_classification_base, -> (taxon_name_class_name_base) { includes(:taxon_name_classifications).where('taxon_name_classifications.type LIKE ?', "#{taxon_name_class_name_base}%").references(:taxon_name_classifications) }
  scope :with_taxon_name_classification_containing, -> (taxon_name_class_name_fragment) { includes(:taxon_name_classifications).where('taxon_name_classifications.type LIKE ?', "%#{taxon_name_class_name_fragment}%").references(:taxon_name_classifications) }
  scope :with_taxon_name_classification_array, -> (taxon_name_class_name_base_array) { includes(:taxon_name_classifications).where('taxon_name_classifications.type in (?)', taxon_name_class_name_base_array).references(:taxon_name_classifications) }
  scope :without_taxon_name_classification, -> (taxon_name_class_name) { where('"taxon_names"."id" not in (SELECT taxon_name_id FROM taxon_name_classifications WHERE type LIKE ?)', "#{taxon_name_class_name}")}
  scope :without_taxon_name_classification_array, -> (taxon_name_class_name_array) { where('"taxon_names"."id" not in (SELECT taxon_name_id FROM taxon_name_classifications WHERE type in (?))', taxon_name_class_name_array) }
  scope :without_taxon_name_classifications, -> { includes(:taxon_name_classifications).where(taxon_name_classifications: {taxon_name_id: nil}) }
  scope :with_type_material_array, ->  (type_material_array) { joins('LEFT OUTER JOIN "type_materials" ON "type_materials"."protonym_id" = "taxon_names"."id"').where("type_materials.collection_object_id in (?) AND type_materials.type_type in ('holotype', 'neotype', 'lectotype', 'syntype', 'syntypes')", type_material_array) }
  scope :with_type_of_taxon_names, -> (type_id) { includes(:related_taxon_name_relationships).where("taxon_name_relationships.type LIKE 'TaxonNameRelationship::Typification%' AND taxon_name_relationships.subject_taxon_name_id = ?", type_id).references(:related_taxon_name_relationships) }
  scope :with_homonym_or_suppressed, -> { includes(:taxon_name_relationships).where("taxon_name_relationships.type LIKE 'TaxonNameRelationship::Iczn::Invalidating::Homonym%' OR taxon_name_relationships.type LIKE 'TaxonNameRelationship::Iczn::Invalidating::Suppression::Total'").references(:taxon_name_relationships) }
  scope :without_homonym_or_suppressed, -> { where("id not in (SELECT subject_taxon_name_id FROM taxon_name_relationships WHERE taxon_name_relationships.type LIKE 'TaxonNameRelationship::Iczn::Invalidating::Homonym%' OR taxon_name_relationships.type LIKE 'TaxonNameRelationship::Iczn::Invalidating::Usage%' OR taxon_name_relationships.type LIKE 'TaxonNameRelationship::Iczn::Invalidating::Misapplication' OR taxon_name_relationships.type LIKE 'TaxonNameRelationship::Iczn::Invalidating::Suppression::Total')") }
  scope :with_primary_homonym, -> (primary_homonym) {where(cached_primary_homonym: primary_homonym)}
  scope :with_primary_homonym_alternative_spelling, -> (primary_homonym_alternative_spelling) {where(cached_primary_homonym_alternative_spelling: primary_homonym_alternative_spelling)}
  scope :with_secondary_homonym, -> (secondary_homonym) {where(cached_secondary_homonym: secondary_homonym)}
  scope :with_secondary_homonym_alternative_spelling, -> (secondary_homonym_alternative_spelling) {where(cached_secondary_homonym_alternative_spelling: secondary_homonym_alternative_spelling)}

  # TODO, move to IsData or IsProjectData
  scope :with_project, -> (project_id) {where(project_id:)}

  scope :is_species_group, -> { where("taxon_names.rank_class ILIKE '%speciesgroup%'") }
  scope :is_genus_group, -> { where("taxon_names.rank_class ILIKE '%genusgroup%'") }
  scope :is_family_group, -> { where("taxon_names.rank_class ILIKE '%family%'") }
  scope :is_species_or_genus_group, -> { where("taxon_names.rank_class ILIKE '%speciesgroup%' OR taxon_names.rank_class ILIKE '%genusgroup%'")   }

  scope :is_original_name, -> { where("taxon_names.cached_author_year NOT ILIKE '(%'") }
  scope :is_not_original_name, -> { where("taxon_names.cached_author_year ILIKE '(%'") }

  after_initialize :_initialize_cached_build_state

  # Reset memomized and utility variables on reload.
  def reload(*)
    super.tap do
      @_initialize_cached_build_state = {}
      @original_combination_elements = nil
    end
  end

  # @return [Protonym]
  #   a name ready to become the root
  def self.stub_root(project_id: nil, by: nil)
    Protonym.new(name: 'Root', rank_class: 'NomenclaturalRank', parent_id: nil, project_id:, by:)
  end

  # TODO: Move to Utilities::Nomenclature, rename iczn_family_group_base
  def self.family_group_base(name_string)
    name_string.match(/(^.*)(ini|ina|inae|idae|oidae|odd|ad|oidea)$/)
    $1 || name_string
  end

  # TODO: replace with @taxonomy
  def self.family_group_name_at_rank(name_string, rank_string)
    if name_string == Protonym.family_group_base(name_string)
      name_string
    else
      Protonym.family_group_base(name_string) + Ranks.lookup(:iczn, rank_string).constantize.try(:valid_name_ending).to_s
    end
  end

  # TODO: feels like TaxonNames Filter f(n)
  # @param rank full String to match rank_class, like '%genusgroup%' or '%::Family'
  #    scope to names used in taxon determinations
  #  !! Ensure collection_object_query is scoped to project
  def self.names_at_rank_group_for_collection_objects(rank: nil, collection_object_query: nil)
    # Find all the names for the objects in question
    names = ::Queries::TaxonName::Filter.new(collection_object_query:).all

    s = 'WITH q_co_names AS (' + names.distinct.all.to_sql + ') ' +
      ::Protonym
      .joins('JOIN taxon_name_hierarchies tnh on tnh.ancestor_id = taxon_names.id')
      .joins('JOIN q_co_names as q_co1 on q_co1.id = tnh.descendant_id')
      .where('taxon_names.rank_class ilike ?', rank)
      .to_sql

    ::Protonym.from('(' + s + ') as taxon_names').distinct
  end

  # @return Scope
  #   unavailable Protonyms as inferred from the data
  # Note that Combinations are considered innaplicable, and are treated as unavailable for data-persistence purposes.
  def self.calculated_unavailable
    a = Protonym.joins(:taxon_name_relationships).where(taxon_name_relationships: {type: TAXON_NAME_RELATIONSHIP_NAMES_MISSPELLING_AND_MISAPPLICATION})
    b = Protonym.joins(:taxon_name_classifications).where(taxon_name_classifications: {type: TAXON_NAME_CLASS_NAMES_UNAVAILABLE})

    ::Queries.union(TaxonName, [a,b])
  end

  # A convenience method to make this
  # name a low-level synonym of another.
  # Presently limited in scope to names that share rank (not rank group)
  def synonymize_with(protonym)
    return false if protonym.nil?
    return false if protonym.rank_class.to_s != rank_class.to_s

    begin
      case nomenclatural_code
      when  :iczn
        TaxonNameRelationship::Iczn::Invalidating::Synonym.create!(subject_taxon_name: self, object_taxon_name: protonym)
      when :icn
        TaxonNameRelationship::Icn::Unaccepting::Synonym.create!(subject_taxon_name: self, object_taxon_name: protonym)
      when :icnp
        TaxonNameRelationship::Icnp::Unaccepting::Synonym.create!(subject_taxon_name: self, object_taxon_name: protonym)
      when :icvnc
        TaxonNameRelationship::Icnp::Unaccepting::SupressedSynony.create!(subject_taxon_name: self, object_taxon_name: protonym)
      else
        return false
      end
    rescue ActiveRecord::RecordInvalid
      return false
    end
  end

  # @return [Array of Strings]
  #   genera where the species was placed
  # TODO: Move to Homonym logic, it's only used there
  def all_generic_placements
    valid_name = get_valid_taxon_name  # TODO: depend on cached
    return nil unless valid_name.rank_string !=~/Species/
    descendants_and_self = valid_name.descendants.unscope(:order) + [self] + self.combinations
    relationships = TaxonNameRelationship.where_object_in_taxon_names(descendants_and_self).with_two_type_bases('TaxonNameRelationship::OriginalCombination::OriginalGenus', 'TaxonNameRelationship::Combination::Genus')
    (relationships.collect { |r| r.subject_taxon_name.name } + [self.ancestor_at_rank('genus').try(:name)]).uniq
  end

  # @return Array
  #     Protonyms
  # TODO: @proceps - define/describe this
  def list_of_coordinated_names
    list = []

    if self.rank_string  ## All Protonym must have this.

      if cached_misspelling
        list = [ self.iczn_set_as_incorrect_original_spelling_of_relationship&.object_taxon_name ].compact
      else

        search_rank = NomenclaturalRank::Iczn.group_base(rank_string)
        if !!search_rank # how can this not hit?
          if search_rank =~ /Family/
            if cached_is_valid
              z = Protonym.family_group_base(name)
              search_name = z.nil? ? nil : Protonym::FAMILY_GROUP_ENDINGS.collect{|i| z+i} # ! array
            else
              search_name = nil
            end
          else
            search_name = self.name
          end
        else
          search_name = nil
        end

        #  r = TaxonNameRelationship.where_subject_is_taxon_name(self).with_type_array(TAXON_NAME_RELATIONSHIP_NAMES_MISSPELLING)
        #  if !search_name.nil? && r.empty?
        if !search_name.blank? && cached_is_available
          list = Protonym
            .ancestors_and_descendants_of(self)
            .with_rank_class_including(search_rank)
            .where(name: search_name)
            .not_self(self)
            .that_is_valid
            .unscope(:order)
        else
          list = []
        end
      end

    end
    list
  end

  # @return [Boolean]
  def has_misspelling_or_misapplication_relationship?
    # TODO: Looping the constant and meomizing the taxon_name_relationships prevents another query
    taxon_name_relationships.where(type: TAXON_NAME_RELATIONSHIP_NAMES_MISSPELLING_AND_MISAPPLICATION).any?
  end

  # @return Boolean
  #   See cached_is_available attribute in TaxonName
  def get_is_available
    !has_misspelling_or_misapplication_relationship? && !classification_unavailable?
  end

  # @return [Protonym]
  #   the accepted "valid" version of this name in the present classification
  def get_valid_taxon_name
    v = first_possible_valid_taxon_name
    if v == self
      self
    elsif v.cached_valid_taxon_name_id == v.id
      v
    elsif !v.cached_valid_taxon_name_id.nil?
      v.valid_taxon_name
    else
      self
    end
  end

  # This method is currently only used for setting cached_primary_homonym.
  #
  # @return [nil, false, String]
  #   !! Why both?
  def get_genus_species(genus_option, self_option)
    return nil if rank_class.nil? || rank_class.to_s == 'NomenclaturalRank'

    genus = nil
    name1 = nil

    if is_species_rank?
      if genus_option == :original
        genus = original_genus
      elsif genus_option == :current
        genus = ancestor_at_rank('genus') # @taxonomy
      else
        return false
      end

      genus = genus.name if genus.present?
      return nil if genus.blank?
    end

    if self_option == :self
      name1 = name
    elsif self_option == :alternative
      name1 = name_with_alternative_spelling
    end

    return nil if genus.nil? && name1.nil? # <- hitting this because Genus is never set
    [genus, name1].compact.join(' ')
  end

  # @return Protonym
  def lowest_rank_coordinated_taxon
    list = [self] + list_of_coordinated_names
    if list.count == 1
      self
    else
      parents = list.collect{|i| i.parent.id}
      list.detect{|t| !parents.include?(t.id)}
    end
  end

  # @return [Array]
  #    all descendant and ancestor protonyms for this Protonym
  def ancestors_and_descendants
    Protonym.ancestors_and_descendants_of(self).not_self(self).unscope(:order).to_a
  end

  ## taxon_name.predicted_children_rank('Cicadellidae') >> NomenclaturalRank::Iczn::FamilyGroup::Family
  def predicted_child_rank(child_string)
    return nil if child_string.blank?
    parent_rank = rank_class.to_s
    parent_rank_name = rank_name
    ncode = nomenclatural_code

    return nil if ncode.nil? # Happens with some names like "Root"

    if child_string == child_string.downcase
      if !is_species_rank?
        r = Ranks.lookup(ncode, 'species')
      elsif parent_rank_name == 'species'
        r = Ranks.lookup(ncode, 'subspecies')
      elsif parent_rank_name == 'subspecies'
        r = Ranks.lookup(ncode, 'variety')
      elsif parent_rank_name == 'variety'
        r = Ranks.lookup(ncode, 'form')
      elsif parent_rank_name == 'form'
        r = Ranks.lookup(ncode, 'subform')
      else
        return nil
      end
    elsif child_string == child_string.capitalize
      if rank_name == 'genus'
        r = Ranks.lookup(ncode, 'subgenus')
      else
        Ranks.lookup(ncode, 'family').constantize.valid_parents.each do |r1|
          r2 = r1.constantize
          if r2.valid_name_ending.present? && child_string.end_with?(r2.valid_name_ending) && r2.typical_use && RANKS.index(r1) > RANKS.index(parent_rank)
            r = r1
            break
          end
        end
        r = Ranks.lookup(ncode, 'genus') if r.nil?
      end
    else
      return nil
    end
    return nil if r.nil?
    r.constantize
  end

  # TODO: Move to helper or lib/
  # temporary method to get a number of taxa described by year
  def number_of_taxa_by_year
    file_name = '/tmp/taxa_by_year' + '_' + Time.now.to_i.to_s + '.csv'
    a = {}
    descendants.find_each do |z|
      year = z.year_integer
      year = 0 if year.nil?
      a[year] = {valid: 0, synonyms: 0} unless a[year]
      if z.rank_string == 'NomenclaturalRank::Iczn::SpeciesGroup::Species'
        if z.cached_is_valid
          a[year][:valid] = a[year][:valid] += 1
        elsif TaxonNameRelationship.where_subject_is_taxon_name(z.id).where(type: ::TAXON_NAME_RELATIONSHIP_NAMES_SYNONYM).any?
          a[year][:synonyms] = a[year][:synonyms] += 1
        end
      end
    end
    for i in 1758..Time.now.year do
      a[i] = {valid: 0, synonyms: 0} unless a[i]
    end
    b = a.sort.to_h
    CSV.open(file_name, 'w') do |csv|
      #CSV.generate do |csv|
      csv << ['year', 'valid species', 'synonyms']
      b.keys.each do |i|
        csv << [i, b[i][:valid], b[i][:synonyms]]
      end
    end
  end

  # @return [ TypeMaterial, [] ]  ?!
  def get_primary_type
    return [] unless self.rank_class.parent.to_s =~ /Species/
    s = self.type_materials.syntypes
    p = self.type_materials.primary
    if s.empty? && p.count == 1
      p
    elsif p.empty? && !s.empty?
      s
    else
      []
    end
  end

  # !! TODO: Should not be possible- fix the incoming data
  # @return [Boolean]
  #    true if taxon2 has the same primary type
  def has_same_primary_type(taxon2)
    return true unless rank_class.parent.to_s =~ /Species/

    taxon1_types = get_primary_type.sort_by{|i| i.id}
    taxon2_types = taxon2.get_primary_type.sort_by{|i| i.id}
    return true if taxon1_types.empty? && taxon2_types.empty?  # both are empty !! If they are both empty then they don't have the same type, they have no types  !!
    return false if taxon1_types.empty? || taxon2_types.empty? # one is empty

    taxon1_types.map(&:collection_object_id) == taxon2_types.map(&:collection_object_id) # collect{|i| i.collection_object_id}
  end

  # return [Array]
  #  TaxonNameRelationship classes that are applicable to this name, as deterimined by Rank
  def original_combination_class_relationships
    relations = []
    TaxonNameRelationship::OriginalCombination.descendants.each do |r|
      relations.push(r) if r.valid_object_ranks.include?(self.rank_string)
    end
    relations
  end

  # @return [Array]
  #   A relationships for each possible original combination relationship
  def original_combination_relationships_and_stubs
    # TODO: figure out where to really put this, likely in one big sort
    display_order = [ :original_genus, :original_subgenus, :original_species, :original_subspecies, :original_variety, :original_subvariety, :original_form, :original_subform ]

    defined_relations = self.original_combination_relationships.all
    created_already  = defined_relations.collect{|a| a.class}
    new_relations  = []

    original_combination_class_relationships.each do |r|
      new_relations.push( r.new(object_taxon_name: self) ) if !created_already.include?(r)
    end

    (new_relations + defined_relations).sort{|a,b|
      display_order.index(a.class.inverse_assignment_method) <=> display_order.index(b.class.inverse_assignment_method)
    }
  end

  # @return [Boolean]
  #   whether this name has one of the TaxonNameClassifications that except it from being tested as latinized
  def has_latinized_exceptions?
    # The second half of this handles classifications in memory, as required to save a non-latinized name (i.e. don't tune it to .any?)
    # !((type == 'Protonym') && (taxon_name_classifications.collect{|t| t.type} & EXCEPTED_FORM_TAXON_NAME_CLASSIFICATIONS).empty?)

    # Is faster than above?
    #    return true if rank_string =~ /Icnp/ && (name.start_with?('Candidatus ') || name.start_with?('Ca. '))

    return true if is_family_rank? && !family_group_name_form_relationship.nil?
    return true if is_family_rank? && !(taxon_name_relationships.collect{|i| i.type} & ::TAXON_NAME_RELATIONSHIP_NAMES_SYNONYM).empty?
    return true unless (taxon_name_classifications.collect{|i| i.type} & ::EXCEPTED_FORM_TAXON_NAME_CLASSIFICATIONS).empty?
    return true unless (taxon_name_relationships.collect{|i| i.type} & ::TAXON_NAME_RELATIONSHIP_NAMES_MISSPELLING).empty?
    false
  end

  def is_latin?
    !NOT_LATIN.match(name) || has_latinized_exceptions? || rank_string =~ /Icvcn::Species/
  end

  # @return [Boolean]
  #   whether this name has one of the TaxonNameRelationships which justify wrong form of the name
  def has_misspelling_relationship?
    # taxon_name_relationships.with_type_array(TAXON_NAME_RELATIONSHIP_NAMES_MISSPELLING).any?
    if cached_misspelling || cached_original_combination_html.to_s.include?('[sic]')
      return true
    else
      return false
    end
  end

  def has_alternate_original?
    cached_original_combination && (cached != cached_original_combination) ? true : false
  end

  def is_species_rank?
    SPECIES_RANK_NAMES.include?(rank_string)
  end

  def is_genus_rank?
    GENUS_RANK_NAMES.include?(rank_string)
  end

  def is_genus_or_species_rank?
    GENUS_AND_SPECIES_RANK_NAMES.include?(rank_string)
  end

  def is_family_or_genus_or_species_rank?
    FAMILY_AND_GENUS_AND_SPECIES_RANK_NAMES.include?(rank_string)
  end

  def is_family_rank?
    FAMILY_RANK_NAMES.include?(rank_string)
  end

  def is_higher_rank?
    HIGHER_RANK_NAMES.include?(rank_string)
  end

  # @return Boolean
  def is_original_name?
    cached_author_year =~ /\(/ ? false : true
  end

  # @return Boolean
  def has_latinized_classification?
    TaxonNameClassification.where_taxon_name(self).where(type: LATINIZED_TAXON_NAME_CLASSIFICATION_NAMES).any?
  end

  def reduce_list_of_synonyms(list)
    return [] if list.empty?
    list1 = list.select{|s| s.id == s.lowest_rank_coordinated_taxon.id}
    list1.reject!{|s| self.cached_valid_taxon_name_id == s.cached_valid_taxon_name_id} unless list1.empty?
    unless list1.empty?
      date1 = self.cached_nomenclature_date
      unless date1.nil?
        list1.reject!{|s| date1 < (s.cached_nomenclature_date ? s.cached_nomenclature_date : Time.utc(1))}
      end
    end
    list1
  end

  # TODO: refactor for Utilities::Nomenclature
  def name_with_alternative_spelling
    if rank_class.nil? || nomenclatural_code != :iczn
      # rank_string =~ /::Icn::/ # self.class != Protonym
      return nil
    elsif is_species_rank? # rank_string =~ /Species/
      n = name.squish # remove extra spaces and line brakes
      n = n.split(' ').last
      n = n[0..-4] + 'ae' if n =~ /^[a-z]*iae$/ # -iae > -ae in the end of word
      n = n[0..-6] + 'orum' if n =~ /^[a-z]*iorum$/ # -iorum > -orum
      n = n[0..-6] + 'arum' if n =~ /^[a-z]*iarum$/ # -iarum > -arum
      n = n[0..-3] + 'a' if n =~ /^[a-z]*um$/ # -um > -a
      n = n[0..-3] + 'a' if n =~ /^[a-z]*us$/ # -us > -a
      n = n[0..-3] + 'e' if n =~ /^[a-z]*is$/ # -is > -e
      n = n[0..-3] + 'ra' if n =~ /^[a-z]*er$/ # -er > -ra
      n = n[0..-7] + 'ensis' if n =~ /^[a-z]*iensis$/ # -iensis > -ensis
      n = n[0..-5] + 'ana' if n =~ /^[a-z]*iana$/ # -iana > -ana
      n = n.gsub('ae', 'e') if n =~ /^[a-z]*ae[a-z]+$/ # -ae-
      n = n.gsub('oe', 'e').
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
    elsif rank_string =~ /Family/
      n_base = Protonym.family_group_base(self.name)
      if n_base.nil? || n_base == self.name
        n = self.name
      else
        n = n_base + 'idae'
      end
    else
      n = self.name.squish
    end

    return n
  end

  def genus_suggested_gender
    return nil unless rank_string =~/Genus/
    TAXON_NAME_CLASSIFICATION_GENDER_CLASSES.each do |g|
      g.possible_genus_endings.each do |e|
        return g.name.demodulize.underscore.humanize.downcase if self.name =~ /^[a-zA-Z]*#{e}$/
      end
    end
    nil
  end

  def species_questionable_ending(taxon_name_classification_class, tested_name)
    return nil unless is_species_rank?
    taxon_name_classification_class.questionable_species_endings.each do |e|
      return e if tested_name =~ /^[a-z]*#{e}$/
    end
    nil
  end

  # TODO: likley belongs in lib/vendor/biodiversity.rb
  # @return [Boolean]
  #   Wraps set_original_combination with result from Biodiversity parse
  #   !!You must can optionally pre-calculate a disambiguated protonym if you wish to use one.
  # @param biodiversity_result [ Biodiversity.result ]
  # @param relationship_housekeeping [Hash] like `{project_id: 22, created_by_id: 2}`
  def build_original_combination_from_biodiversity(biodiversity_result, relationship_housekeeping = {})
    br = biodiversity_result
    return false if br.nil?
    c = [br.disambiguated_combination, br.combination].first
    build_original_combinations(c, relationship_housekeeping)
    true
  end

  # @return [Boolean]
  # @param combination [Combination]
  # @param relationship_housekeeping [Hash] like `{project_id: 22, created_by_id: 2}`
  #   builds, but does not save, original relationships for all corresponding protonyms in a combination
  #   !! Replaces existing relationship without checking identify if they are there!
  def build_original_combinations(combination, relationship_housekeeping)
    return false if combination.nil?

    combination.protonyms_by_rank.each do |rank, p|
      send("original_#{rank}=", p)
    end

    unless relationship_housekeeping.blank?
      combination.protonyms_by_rank.each do |rank, p|
        r = send("original_#{rank}_relationship")
        r.write_attributes(relationship_housekeeping)
      end
    end
    true
  end


  # @return [[rank_name, name], nil]
  #   Used in ColDP export
  def original_combination_infraspecific_element(elements = nil, remove_sic = false)
    elements ||= original_combination_elements

    elements = elements.each { |r, e| e.delete('[sic]') } if remove_sic

    # TODO: consider plants/other codes?
    [:form, :variety, :subspecies].each do |r|
      return [r.to_s, elements[r].last] if elements[r]
    end
    nil
  end

  def update_cached_original_combinations
    # if @pp
    #   @pp += 1
    # else
    #   @pp = 1
    # end
    update_columns(
      cached_original_combination: get_original_combination,
      cached_original_combination_html: get_original_combination_html,
      cached_primary_homonym: get_genus_species(:original, :self),
      cached_primary_homonym_alternative_spelling: get_genus_species(:original, :alternative))
    # puts Rainbow(@pp).orange.bold
  end

  def set_cached_species_homonym
    update_columns(
      cached_secondary_homonym: get_genus_species(:current, :self),
      cached_secondary_homonym_alternative_spelling: get_genus_species(:current, :alternative)
    )
  end

  # TODO: Are there are times where names are dependant and descendant?
  #   Original Genus is Genus, for example

  def set_cached_names_for_descendants
    dependants = []

    TaxonName.transaction_with_retry do

      if is_genus_or_species_rank?
        dependants = Protonym.unscoped.descendants_of(self).to_a
      end

      dependants.each do |i|
        n = i.get_full_name
        columns_to_update = {
          cached: n,
          cached_html:  i.get_full_name_html(n),
          cached_author_year: i.get_author_and_year,
          cached_nomenclature_date: i.nomenclature_date
        }

        if i.is_species_rank?
          columns_to_update[:cached_secondary_homonym] = i.get_genus_species(:current, :self)
          columns_to_update[:cached_secondary_homonym_alternative_spelling] = i.get_genus_species(:current, :alternative)
        end

        i.update_columns(columns_to_update)
      end
    end
  end

  def set_cached_names_for_dependants
    related_through_original_combination_relationships = []
    combination_relationships = []

    all_names = []

    # This transaction makes it difficult to re-use cached fields to derive other =cached fields,
    # thus the existence of some cachine attributes in TaxonName.
    TaxonName.transaction_with_retry do

      if is_genus_or_species_rank?
        related_through_original_combination_relationships = TaxonNameRelationship.where_subject_is_taxon_name(self).with_type_contains('OriginalCombination')
        combination_relationships = TaxonNameRelationship.where_subject_is_taxon_name(self).with_type_contains('::Combination')
      end

      # byebug if name == 'Dus'

      classified_as_relationships = TaxonNameRelationship.where_object_is_taxon_name(self).with_type_contains('SourceClassifiedAs')

      related_through_original_combination_relationships.collect{|i| i.object_taxon_name}.uniq.each do |i|
        all_names.push i
        i.reload
        #  byebug if name == 'Dus'
        i.update_cached_original_combinations
      end

      # Update values in Combinations
      combination_relationships.collect{|i| i.object_taxon_name}.uniq.each do |j|
        all_names.push j
        n = j.get_full_name
        j.update_columns(
          cached: n,
          cached_html: j.get_full_name_html(n),
          cached_author_year: j.get_author_and_year,     # !! Only if it changed?
          cached_nomenclature_date: j.nomenclature_date) # !! Only if it changed?
      end

      classified_as_relationships.collect{|i| i.subject_taxon_name}.uniq.each do |i|
        i.update_column(:cached_classified_as, i.get_cached_classified_as)
      end

      classified_as_relationships.collect{|i| i.object_taxon_name}.uniq.each do |i|
        all_names.push i
        n = i.get_full_name
        i.update_columns(
          cached: n,
          cached_html: i.get_full_name_html(n),
          cached_author_year: i.get_author_and_year,
          cached_nomenclature_date: i.nomenclature_date)
      end

      misspelling_relationships = TaxonNameRelationship.where_object_is_taxon_name(self).where(type: TAXON_NAME_RELATIONSHIP_NAMES_MISSPELLING_AND_MISAPPLICATION)
      misspelling_relationships.collect{|i| i.subject_taxon_name}.uniq.each do |i|
        all_names.push i
        i.update_columns(
          cached_author_year: i.get_author_and_year,
          cached_nomenclature_date: i.nomenclature_date)
      end
      #  byebug if all_names.uniq.size != all_names.size || all_names.size > 1

    end
  end

  # @return [boolean]
  def nominotypical_sub_of?(protonym)
    is_genus_or_species_rank? && parent == protonym && parent.name == protonym.name
  end

  # @return [Hash]
  def self.batch_move(params)
    return false if params[:parent_id].blank?

    a = Queries::TaxonName::Filter.new(params[:taxon_name_query]).all.where(type: 'Protonym')

    return false if a.count == 0

    moved = []
    unmoved = []

    begin
      a.each do |o|
        if o.update(parent_id: params[:parent_id] )
          moved.push o
        else
          unmoved.push o
        end
      end
    end

    return { moved:, unmoved:}
  end

  # @params params [Hash]
  #   { taxon_name_query: {},
  #     taxon_name_filter_query: {},
  #     async_cutoff: 1
  #   }
  def self.batch_update(params)
    request = QueryBatchRequest.new(
      async_cutoff: params[:async_cutoff] || 50,
      klass: 'TaxonName',
      object_filter_params: params[:taxon_name_query],
      object_params: params[:taxon_name],
      preview: params[:preview],
    )

    query_batch_update(request)
  end

  protected

  def check_new_parent_class
    if is_protonym? && parent_id != parent_id_was && !parent_id_was.nil? && nomenclatural_code == :iczn
      if old_parent = TaxonName.find_by(id: parent_id_was)
        if (rank_name == 'subgenus' || rank_name == 'subspecies') && old_parent.name == name
          errors.add(:parent_id, "The nominotypical #{rank_name} #{name} can not be moved out of the nominal #{old_parent.rank_name}")
        end
      end
    end
  end

  def name_is_latinized
    errors.add(:name, 'Name must be latinized, no digits or spaces allowed') if !is_latin?
  end

  def verbatim_author_without_digits
    errors.add(:verbatim_author, 'Verbatim author may not contain digits, a year may be present') if verbatim_author =~ /\d/
  end

  def verbatim_author_with_closed_parens_when_present
    if verbatim_author.present? and nomenclatural_code != :icn  # workaround until basyonim field exists
      # Regex matches two possible, both params, or no params at start/end
      errors.add(:verbatim_author, 'Verbatim author is missing a parenthesis') unless verbatim_author =~ /\A\([^()]+\)\z|\A[^()]+\z/
    end
  end

  def name_is_valid_format
    rank_class.validate_name_format(self) if name.present? && rank_class && rank_class.respond_to?(:validate_name_format) && !has_latinized_exceptions?
  end

  def new_parent_taxon_name
    r = self.iczn_uncertain_placement_relationship
    if r.present?
      if self.parent != r.object_taxon_name
        errors.add(:parent_id, "Taxon has an 'Incertae sedis' relationship, which prevent the parent modifications, change the relationship to 'Source classified as' before updating the parent")
      end
    end
  end

  def validate_rank_class_class
    errors.add(:rank_class, 'Rank not found') unless RANKS.include?(rank_string)
  end

  def validate_child_rank_is_equal_or_lower
    if parent && rank_class.present? && rank_string != 'NomenclaturalRank'
      if rank_class_changed?
        a = children.where(type: 'Protonym').pluck(:rank_class)
        v = RANKS.index(rank_string)
        a.each do |b|
          if v >= RANKS.index(b)
            errors.add(:rank_class, "The rank of this taxon (#{rank_name}) should be higher than the ranks of children")
            break
          end
        end
      end
    end
  end

  def validate_parent_rank_is_higher
    if parent && rank_class.present? && rank_string != 'NomenclaturalRank'
      if RANKS.index(rank_string).to_i <= RANKS.index(parent.rank_string).to_i
        errors.add(:parent_id, "The parent rank (#{parent.rank_class.rank_name}) is not higher than the rank (#{rank_name}) of this taxon")
      end
    end
  end

  def validate_same_nomenclatural_code
    if parent&.nomenclatural_code && nomenclatural_code != parent.nomenclatural_code
      errors.add(:rank_class, "The parent nomenclatural code (#{parent.nomenclatural_code.to_s.upcase}) is not matching to the nomenclatural code (#{nomenclatural_code.to_s.upcase}) of this taxon")
    end
  end

  # !! This has to go. A single method is meaningless to the user and to developers.  Which cached is the problem it the problem?
  # We simply can't tell what went wrong in this case.
  #
  # This is a *very* expensive soft validation, it should be fragemented into individual parts likely.
  # It should also not be necessary by default our code should be good enough to handle these
  # issues in the long run.
  # DD: rules for cached tend to evolve, what was good in the past, may not be true today
  # MJY: If the meaning of cached changes then it should be removed, not changed.
  def sv_cached_names # this cannot be moved to soft_validation_extensions
  is_cached = true

  is_cached = false if cached_author_year != get_author_and_year
  is_cached = false if cached_author != get_author

  n = get_full_name

  # TODO: missing `cached_gender`
  # TODO: missing `cached` ?!

  # Right side values should call methods that calculate from the db
  if is_cached && (
      cached_valid_taxon_name_id != get_valid_taxon_name.id ||
      cached_is_valid != !unavailable_or_invalid? ||
      cached_is_available != get_is_available ||
      cached_html != get_full_name_html(n) ||
      cached_misspelling != get_cached_misspelling ||
      cached_original_combination != get_original_combination ||
      cached_original_combination_html != get_original_combination_html ||
      cached_primary_homonym != get_genus_species(:original, :self) ||
      cached_nomenclature_date != nomenclature_date ||
      cached_primary_homonym_alternative_spelling != get_genus_species(:original, :alternative) ||
      rank_string =~ /Species/ &&
      (cached_secondary_homonym != get_genus_species(:current, :self) ||
       cached_secondary_homonym_alternative_spelling != get_genus_species(:current, :alternative)))

    is_cached = false
  end

  soft_validations.add(
    :base, 'Cached values should be updated',
    success_message: 'Cached values were updated',
    failure_message:  'Failed to update cached values') unless is_cached
  end

  def set_cached
    return true if destroyed?
    old_cached_author_year = cached_author_year.to_s # why to_s?
    old_cached = cached.to_s # why to_s?

    super

    if parent_id || parent # Don't do this for Root!!
      set_original_combination_cached_fields
      set_cached_homonymy
      set_cached_species_homonym if is_species_rank?
      set_cached_misspelling

      # Here we start to calculate off of what was previously set
      tn = TaxonName.find(id) # Why not "reload" (maybe OK with re-initialize)
      set_cached_names_for_descendants if tn.cached != old_cached
      set_cached_names_for_dependants if tn.cached.to_s != old_cached || tn.cached_author_year.to_s != old_cached_author_year
    end
    true
  end

  def set_cached_homonymy
    update_columns(
      cached_primary_homonym: get_genus_species(:original, :self),
      cached_primary_homonym_alternative_spelling: get_genus_species(:original, :alternative)
    )
  end

  # The only reason this is needed on this side is because
  # of the verbatim_name checks, otherwise we could drive
  # it from the TaxonNameRelationship creation.
  def set_cached_misspelling
    update_column(:cached_misspelling, get_cached_misspelling)
  end

  def set_cached_original_combination
    update_column(:cached_original_combination, get_original_combination)
  end

  def set_cached_original_combination_html
    update_column(:cached_original_combination_html, get_original_combination_html)
  end

  # All cached values that relate to an original combination should
  # be referenced here so that they can be re-referenced indirectly from TaxonNameRelationships
  # In particular those impacted by an OriginalCombination.
  def set_original_combination_cached_fields
    set_cached_original_combination
    set_cached_original_combination_html
  end

  def _initialize_cached_build_state
    @_cached_build_state = {}
  end

  end
