# A nomenclator name, composed of existing {Protonym}s. Each record reflects the subsequent use of two or more protonyms.
# Only the first use of a combination is stored here, subsequence uses of this combination are referenced in Citations.
#
# A {Combination} has no name, it exists to group related Protonyms into an epithet.
#
# They are applicable to genus group names and finer epithets.
#
# All elements of the combination must be defined, nothing is assumed based on the relationship to the parent.
#
#  c = Combination.new
#  c.genus = a_protonym_genus
#  c.species = a_protonym_species
#  c.save # => true
#  c.genus_taxon_name_relationship  # => A instance of TaxonNameRelationship::Combination::Genus
#
#  # or
#
#  c = Combination.new(genus: genus_protonym, species: species_protonym)
#
# Getters and setters for each of the APPLICABLE_RANKS are available:
#   `genus subgenus section subsection series subseries species subspecies variety subvariety form subform`
#   `genus_id subgenus_id section_id subsection_id series_id subseries_id species_id subspecies_id variety_id subvariety_id form_id subform_id`
#
# You can do things like (notice mix/match of _id or not):
#   c = Combination.new(genus_id: @genus_protonym.id, subspecies: @some_species_group)
#   c.species_id = Protonym.find(some_species_id).id
# or
#   c.species = Protonym.find(some_species_id)
#
# Combinations are composed of TaxonNameRelationships.
# In those relationship the Combination#id is always the `object_taxon_name_id`, the
# individual Protonyms are stored in `subject_taxon_name_id`.
#
# @!attribute combination_verbatim_name
#   Use with caution, and sparingly! If the combination of values from Protonyms can not reflect the formulation of the combination as provided by the original author that string can be provided here.
#   The verbatim value is not further parsed. It is only provided to clarify what the combination looked like when first published.
#   The following recommendations are made:
#     1) The provided string should visually reflect as close as possible what was seen in the publication itself, including
#     capitalization, accented characters etc.
#     2) The full epithet (combination) should be provided, not just the differing component part (see 3 below).
#     3) Misspellings can be more acurately reflected by creating new Protonyms.
#   Example uses:
#     1) Jones 1915 publishes Aus aus. Smith 1920 uses, literally "Aus (Bus) Janes 1915".
#        It is clear "Janes" is "Jones", therefor "Aus (Bus) Janes 1915" is provided as combination_verbatim_name.
#     2) Smith 1800 publishes Aus Jonesi (i.e. Aus jonesi). The combination_combination_verbatim name is used to
#        provide the fact that Jonesi was capitalized.
#     3) "Aus brocen" is used for "Aus broken".  If the curators decide not to create a new protonym, perhaps because
#        they feel "brocen" was a printing press error that left off the straight bit of the "k" then they should minimally
#        include "Aus brocen" in this field, rather than just "brocen". An alternative is to create a new Protonym "brocen".
#     4) 'Aus (Aus)' was originally described in 1920.  "(Aus)" was used in a new combination alone as "Aus".  This is the only case
#        in which combination may contain a single protonym.
#   @return [String]
#
# @!attribute parent_id
#   the parent is the *parent* of the highest ranked component Protonym, it is automatically set i.e. it should never be assigned directly
#   @return [Integer]
#
class Combination < TaxonName
  # The ranks that can be used to build a Combination pointing to the corresponding TaxonNameRelationship type
  APPLICABLE_RANKS = %w{genus subgenus section subsection series subseries species subspecies variety subvariety form subform}.inject({}){|hsh,r|
    hsh[r] = "TaxonNameRelationship::Combination::#{r.capitalize}"; hsh;
  }.freeze

  INVERTED_RANKS = APPLICABLE_RANKS.dup.invert.freeze

  APPLICABLE_RANK_CLASSES = INVERTED_RANKS.keys.freeze

  APPLICABLE_RANK_SORT = INVERTED_RANKS.keys.inject({}){|hsh, r| hsh[r] = INVERTED_RANKS.keys.index(r) || 0 + 1; hsh}.freeze

  before_validation :set_parent

  # Before we set cached ensure we draw current data
  after_save :reset_protonyms_by_rank

  validate :validate_absence_of_subject_relationships

  # TODO: make access private
  attr_accessor :disable_combination_relationship_check

  # Memoize.
  attr_accessor :protonyms_by_rank

  # Overwritten here from TaxonName to allow for destroy
  has_many :related_taxon_name_relationships, class_name: 'TaxonNameRelationship',
    foreign_key: :object_taxon_name_id,
    inverse_of: :object_taxon_name,
    dependent: :destroy

  has_many :combination_relationships, -> {
    joins(:taxon_name_relationships)
    where("taxon_name_relationships.type LIKE 'TaxonNameRelationship::Combination::%'")
  }, class_name: 'TaxonNameRelationship',
  foreign_key: :object_taxon_name_id

  has_many :combination_taxon_names, through: :combination_relationships, source: :subject_taxon_name # Should be combination_protonyms, or just protonyms?

  # Create syntactic helper methods
  TaxonNameRelationship.descendants.each do |d|
    if d.respond_to?(:assignment_method)
      if d.name.to_s =~ /TaxonNameRelationship::SourceClassifiedAs/
        relationship = "#{d.assignment_method}_relationship".to_sym
        has_one relationship, class_name: d.name.to_s, foreign_key: :subject_taxon_name_id
        has_one d.assignment_method.to_sym, through: relationship, source: :object_taxon_name
      end

      if d.name.to_s =~ /TaxonNameRelationship::Combination/ # |SourceClassifiedAs
        relationships = "#{d.assignment_method}_relationships".to_sym
        has_many relationships, -> {
          where('taxon_name_relationships.type LIKE ?', d.name + '%')
        }, class_name: 'TaxonNameRelationship', foreign_key: :subject_taxon_name_id
        has_many d.assignment_method.to_s.pluralize.to_sym, through: relationships, source: :object_taxon_name
      end
    end

    if d.respond_to?(:inverse_assignment_method)
      if d.name.to_s =~ /TaxonNameRelationship::SourceClassifiedAs/
        relationships = "#{d.inverse_assignment_method}_relationships".to_sym
        has_many relationships, -> {
          where('taxon_name_relationships.type LIKE ?', d.name + '%')
        }, class_name: 'TaxonNameRelationship', foreign_key: :object_taxon_name_id
        has_many d.inverse_assignment_method.to_s.pluralize.to_sym, through: relationships, source: :subject_taxon_name
      end

      if d.name.to_s =~ /TaxonNameRelationship::Combination/ # |SourceClassifiedAs
        relationship = "#{d.inverse_assignment_method}_relationship".to_sym
        has_one relationship, class_name: d.name.to_s, foreign_key: :object_taxon_name_id
        has_one d.inverse_assignment_method.to_sym, through: relationship, source: :subject_taxon_name
      end
    end
  end

  APPLICABLE_RANKS.keys.each do |rank|
    has_one "#{rank}_taxon_name_relationship".to_sym, -> {
      joins(:combination_relationships)
      where(taxon_name_relationships: {type: "TaxonNameRelationship::Combination::#{rank.capitalize}"}) },
    class_name: 'TaxonNameRelationship', foreign_key: :object_taxon_name_id, inverse_of: :object_taxon_name

    has_one rank.to_sym, -> {
      joins(:combination_relationships)
      where(taxon_name_relationships: {type: "TaxonNameRelationship::Combination::#{rank.capitalize}"})
    }, through: "#{rank}_taxon_name_relationship".to_sym, source: :subject_taxon_name

    accepts_nested_attributes_for rank.to_sym

    accepts_nested_attributes_for "#{rank}_taxon_name_relationship".to_sym, allow_destroy: true

    attr_accessor "#{rank}_id".to_sym
    method = "#{rank}_id"

    define_method(method) {
      if self.send(rank)
        self.send(rank).id
      else
        nil
      end
    }

    define_method("#{method}=") {|value|
      if value.present?
        if n = Protonym.find(value)
          self.send("#{rank}=", n)
        end
      end
    }
  end

  scope :with_protonym_at_rank, -> (rank, protonym) {
    includes(:combination_relationships).
    where('taxon_name_relationships.type = ? and taxon_name_relationships.subject_taxon_name_id = ?', rank, protonym).
    references(:combination_relationships)}

  scope :incomplete, -> { where("taxon_names.cached LIKE '%NOT SPECIFIED%'") }
  scope :complete, -> { where("taxon_names.cached IS NOT null AND taxon_names.cached NOT LIKE '%NOT SPECIFIED%'") }

  validate :is_unique
  validate :does_not_exist_as_original_combination, unless: Proc.new {|a| a.errors.full_messages.include? 'Combination exists.' }
  validate :parent_is_properly_set , unless: Proc.new {|a| a.errors.full_messages.include? 'Combination exists.' }
  validate :composition, unless: Proc.new {|a| disable_combination_relationship_check == true || a.errors.full_messages.include?('Combination exists.') }
  validates :rank_class, absence: true

  soft_validate(
    :sv_redundant_verbatim_name,
    set: :cached,
    fix: :sv_fix_redundant_verbatim_name,
    name: 'Redundant verbatim name',
    description: 'Verbatim name is present but identical to computed name')


  soft_validate(
    :sv_combination_duplicates,
    set: :combination_duplicates,
    name: 'Duplicate combination',
    description: 'Combination is a duplicate' )

  soft_validate(
    :sv_year_of_publication_matches_source,
    set: :dates,
    name: 'Year of publication does not match the source',
    description: 'The published date of the combination is not the same as provided by the original publication' )

  soft_validate(
    :sv_year_of_publication_not_older_than_protonyms,
    set: :dates,
    name: 'Varbatim year in combination older than in protonyms',
    description: 'The varbatim year in combination is older than in protonyms in the combination' )

  soft_validate(
    :sv_source_not_older_than_protonyms,
    set: :dates,
    name: 'Combination older than protonyms',
    description: 'The combination is older than protonyms in the combination' )

  soft_validate(
    :sv_combination_linked_to_valid_name,
    set: :combination_linked_to_valid_name,
    fix: :sv_fix_combination_parent_update,
    name: 'Combination has valid parent',
    description: 'The combination should have the same parent as protonym' )

  soft_validate(
    :sv_author_and_year_is_not_required,
    set: :year_is_not_required,
    fix: :sv_fix_author_and_year_is_not_required,
    name: 'Verbatim author and year are not required',
    description: 'Verbatim author and year are not required. The Fix will delete both' )

  # @return [Protonym Scope]
  # @params protonym_ids [Hash] like `{genus: 4, species: 5}`
  #   the absence of _id in the keys in part reflects integration with Biodiversity gem
  #   AHA from http://stackoverflow.com/questions/28568205/rails-4-arel-join-on-subquery
  #   See also Descriptor::Gene
  def self.protonyms_matching_original_relationships(protonym_ids = {})
    protonym_ids.compact!
    return Protonym.none if !protonym_ids.keys.any?

    s  = Protonym.arel_table
    sr = TaxonNameRelationship.arel_table

    j = s.alias('j') # required for group/having purposes

    b = s.project(j[Arel.star]).from(j)
      .join(sr)
      .on(sr['object_taxon_name_id'].eq(j['id']))

    # Build an aliased join for each set of attributes
    protonym_ids.each do |rank, id|
      sr_a = sr.alias("b_#{rank}")
      b = b.join(sr_a).on(
        sr_a['object_taxon_name_id'].eq(j['id']),
        sr_a['type'].eq("TaxonNameRelationship::OriginalCombination::Original#{rank.capitalize}"),
        sr_a['subject_taxon_name_id'].eq(id)
      )
    end

    b = b.group(j['id']).having(sr['object_taxon_name_id'].count.eq(protonym_ids.count)).where(sr['type'].in(::COMBINATION_TAXON_NAME_RELATIONSHIP_NAMES))
    b = b.as('join_alias')

    Protonym.joins(Arel::Nodes::InnerJoin.new(b, Arel::Nodes::On.new(b['id'].eq(s['id']))))
  end

  # @return [Protonym Scope] hmmm- a Protonym class method?!
  #    Protonyms matching original relations, if name provided then name added as an additional check on verbatim match
  # @params name [String, nil] the non-htmlized version of the name, without author year
  def self.matching_protonyms(name = nil, **protonym_ids)
    q = nil
    if name.blank?
      q = protonyms_matching_original_relationships(protonym_ids)
    else
      q = protonyms_matching_original_relationships(protonym_ids).where('taxon_names.cached_original_combination = ?', name)
    end
    q
  end

  # @return [Scope]
  # @params keyword_args [Hash] like `{genus: 123, :species: 456}` (note no `_id` suffix)
  def self.find_by_protonym_ids(**keyword_args)
    keyword_args.compact!
    return Combination.none if keyword_args.empty?

    c = Combination.arel_table
    r = TaxonNameRelationship.arel_table

    a = c.alias('a_foo')

    b = c.project(a[Arel.star]).from(a)
      .join(r)
      .on(r['object_taxon_name_id'].eq(a['id']))

    s = []

    i = 0
    keyword_args.each do |rank, id|
      r_a = r.alias("foo_#{i}")
      b = b.join(r_a).on(
        r_a['object_taxon_name_id'].eq(a['id']),
        r_a['type'].eq(TAXON_NAME_RELATIONSHIP_COMBINATION_TYPES[rank]),
        r_a['subject_taxon_name_id'].eq(id)
      )
      i += 1
    end

    b = b.group(a['id']).having(r['object_taxon_name_id'].count.eq(keyword_args.keys.count))
    b = b.as('z_bar')

    Combination.joins(Arel::Nodes::InnerJoin.new(b, Arel::Nodes::On.new(b['id'].eq(c['id']))))
  end

  # @return [Combination, false]
  # @params keyword_args [Hash] like `{genus: 123, :species: 456}` (note no `_id` suffix)
  #    the matching Combination if it exists, otherwise false
  #    if name is provided then cached must match (i.e. verbatim_name if provided must also match)
  def self.match_exists?(name = nil, **keyword_args)
    if name.blank?
      a = find_by_protonym_ids(**keyword_args).first
    else
      a = find_by_protonym_ids(**keyword_args).where(cached: name).first
    end
    a ? a : false
  end

  # TODO: add higher classifcation here
  def combination_taxonomy
    d = full_name_hash
    protonyms_by_rank.to_a.first[1].ancestors.each do |a| # unscope?
      d[a.rank] = a.name
    end

    d
  end

  # This is not used.
  def taxonomy(rebuild = false)
    if rebuild
      @taxonomy = combination_taxonomy
    else
      @taxonomy ||= combination_taxonomy
    end
  end

  # @return [Boolean]
  #   true if the finest level (typically species) currently has the same parent
  def is_current_placement?
    return false if protonyms.second_to_last.nil?
    protonyms.last.parent_id == protonyms.second_to_last.id
  end

  def get_full_name
    return verbatim_name if verbatim_name.present?
    ::Utilities::Nomenclature.full_name(full_name_hash)
  end

  # Overrides {TaxonName#full_name_hash}
  # @return [Hash]
  #
  #  Benchmark.measure { 1000.times do; Combination.find_by_id(ids.sample).full_name_hash; end}
  #
  # TODO: Is this used before persistence of the complete Combination?!
  def full_name_hash
    gender = nil
    data = {}

    light_protonyms_by_rank.each do |rank, i|
      gender = i.cached_gender if rank == 'genus'

      v = i.genderized_elements(gender)
      if ['genus', 'subgenus', 'species', 'subspecies'].include?(rank)
        data[rank] = v
      else
        v[0] = i.rank_class.abbreviation
        data[rank] = v
      end
    end

    if data['genus'].nil?
      data['genus'] = [nil, '[GENUS NOT SPECIFIED]']
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

  # @return [Hash]
  #   Similar pattern to full_name hash
  # !! Does not include '[sic]'
  # !! Does not include 'NOT SPECIFIED' ranks.
  #
  # Intent is to chain with scopes within COLDP export.
  #
  # If this becomes more broadly useful consider optional `sic` includion
  #
  def self.full_name_hash_from_row(row)
    gender = nil
    data = {}

    # protonym loop
    APPLICABLE_RANKS.each do |rank, type|
      if rank == 'genus'
        a = "#{rank}_gender".to_sym
        gender = row[a]
      end

      name_target = gender.nil? ? rank.to_sym : (rank + '_' + gender).to_sym

      # TODO: add  verbatim to row
      name = row[name_target] || row[rank.to_sym] || row[(rank + '_' + 'verbatim')]

      next if name.nil?

      v = [nil, name]

      unless ['genus', 'subgenus', 'species', 'subspecies'].include?(rank)
        v[0] = row[rank + ' ' + 'rank_class']
      end

      data[rank] = v
    end
    data
  end

  # TODO: consider an 'include_cached_misspelling' Boolean to extend result to include `cached_misspelling`
  def self.flattened
    s = []
    abbreviation_cutoff = 'subspecies'
    abbreviate = false
    APPLICABLE_RANKS.each do |rank, t|
      s.push "MAX(combination_taxon_names_taxon_names.name) FILTER (WHERE taxon_name_relationships.type = '#{t}') AS #{rank},
              MAX(combination_taxon_names_taxon_names.neuter_name) FILTER (WHERE taxon_name_relationships.type  = '#{t}') AS #{rank}_neuter,
              MAX(combination_taxon_names_taxon_names.masculine_name) FILTER (WHERE taxon_name_relationships.type =  '#{t}') AS #{rank}_masculine,
              MAX(combination_taxon_names_taxon_names.feminine_name) FILTER (WHERE taxon_name_relationships.type = '#{t}') AS #{rank}_feminine"

      if abbreviate
        s.push "MAX(combination_taxon_names_taxon_names.rank_class) FILTER (WHERE taxon_name_relationships.type = '#{t}') AS #{rank}_rank_class"
      end

      # Include the rank of the genus, which is typicaly there, for reference so we can return the code of nomenclature behind this combination
      s.push "MAX(combination_taxon_names_taxon_names.rank_class) AS reference_rank_class"

      abbreviate = true if rank == abbreviation_cutoff
    end

    # Get the gender designation for genus-group names
    APPLICABLE_RANKS.select{|k,v| v  =~ /[Gg]enus/}.each do |rank, t|
      s.push "MAX(combination_taxon_names_taxon_names.cached_gender) FILTER (WHERE taxon_name_relationships.type = '#{t}') AS #{rank}_gender"
    end

    s.push 'taxon_names.id, taxon_names.cached, taxon_names.cached_author_year, taxon_names.cached_nomenclature_date, taxon_names.updated_by_id, taxon_names.updated_at,sources.id source_id, citations.pages'

    sel = s.join(',')

    Combination.joins(:combination_taxon_names, :source)
      .select(sel)
      .group('taxon_names.id, sources.id, citations.pages')
  end

  # An experimental approach to return all required information to format the
  # scientific name via a single query. Not in use.  Potentially
  # scalable to table rendering in a performant way.
  def protonyms_flat
    s = []
    TAXON_NAME_RELATIONSHIP_COMBINATION_TYPES.select{|n| !n.match('Family')}.each do |rank, t|
      s.push "MAX(name) FILTER (WHERE rt = '#{t}') AS #{rank},
              MAX(cached_gender) FILTER (WHERE rt = '#{t}') AS #{rank}_gender,
              MAX(neuter_name) FILTER (WHERE rt = '#{t}') AS #{rank}_neuter,
              MAX(masculine_name) FILTER (WHERE rt =  '#{t}') AS #{rank}_masculine,
              MAX(feminine_name) FILTER (WHERE rt = '#{t}') AS #{rank}_feminine"
    end

    a = Protonym
      .joins(:combination_relationships)
      .where(taxon_name_relationships: {
        object_taxon_name_id: id
      }).select(
        :id, :name, :cached_gender,
        :neuter_name, :masculine_name, :feminine_name,
        'taxon_name_relationships.type as rt')

      Protonym.with(filtered: a).select(s.join(',')).from('filtered').unscope(:where)[0]
  end

  # @return [Hash of {rank: Protonym}, {}]
  #  the component names for this combination, sorted in order
  #
  def protonyms_by_rank
    if persisted?
      ar = APPLICABLE_RANKS.values

      @protonyms_by_rank ||= TaxonNameRelationship::Combination
        .where(object_taxon_name: self)
        .eager_load(:subject_taxon_name)
        .sort{|a,b| ar.index(a.type) <=> ar.index(b.type)}
        .inject({}){|hsh,n| hsh[n.rank_name] = n.subject_taxon_name; hsh}
        .to_h
    else
      result = {}
      APPLICABLE_RANKS.keys.each do |rank|
        if protonym = send(rank.to_sym)
          result[rank] = protonym
        end
      end
      @protonyms_by_rank = result
    end
    @protonyms_by_rank
  end

  # This is 15s/1000 vs. 40ms/1000 of protonyms_by_rank
  def light_protonyms_by_rank
    if persisted?
      @protonyms_by_rank ||=

        Protonym.joins(:combinations)
        .where(taxon_name_relationships: {object_taxon_name_id: id })
        .select(
          :id, :name, :type, :rank_class, :verbatim_author, :year_of_publication,
          :verbatim_name,
          :neuter_name, :masculine_name, :feminine_name,
          :cached_gender, :cached_misspelling,
          :cached_valid_taxon_name_id,
          'taxon_name_relationships.type tnr_type')
        .sort_by{|a| APPLICABLE_RANK_SORT[a.tnr_type]}
        .each_with_object({}) {|n, h| h[INVERTED_RANKS[n.tnr_type]] = n }

    else
      protonyms_by_rank
    end

    @protonyms_by_rank
  end

  # @return String
  #   like 'species'
  # Adds a lot of SQL overhead
  def inferred_rank
    protonyms_by_rank.to_a.last.first
  end

  # @return [Array of TaxonNames, nil]
  #   return the component names for this combination prior to it being saved
  def protonyms_by_association
    APPLICABLE_RANKS.keys.collect{|r| self.send(r)}.compact
  end

  # @return [Array of TaxonName]
  #   pre-ordered by rank
  def protonyms
    return protonyms_by_association if new_record?
    combination_taxon_names.sort{|a,b| RANKS.index(a.rank_string) <=> RANKS.index(b.rank_string) }
  end

  # @return [Hash]
  #   like `{ genus: 1, species: 2 }`
  def protonym_ids_params
    protonyms_by_rank.inject({}) {|hsh, p| hsh.merge!( p[0].to_sym => p[1].id )}
  end

  # @return [Array of Integers]
  #   the collective years the protonyms were (nomenclaturaly) published on (ordered from genus to below)
  def publication_years
    description_years = protonyms.collect{|a| a.cached_nomenclature_date ? a.cached_nomenclature_date&.year : nil}.compact
  end

  # @return [Integer, nil]
  #   the earliest year (nomenclature) that a component Protonym was published on
  def earliest_protonym_year
    publication_years.sort.first
  end

  # return [Array of TaxonNameRelationship]
  #   classes that are applicable to this name, as deterimned by Rank
  def combination_class_relationships(rank_string)
    relations = []
    TaxonNameRelationship::Combination.descendants.each do |r|
      relations.push(r) if r.valid_object_ranks.include?(rank_string)
    end
    relations
  end

  # TODO: DEPRECATE this is likely not required in our new interfaces
  def combination_relationships_and_stubs(rank_string)
    display_order = [
      :combination_genus, :combination_subgenus, :combination_species, :combination_subspecies, :combination_variety, :combination_form
    ]

    defined_relations = combination_relationships.all
    created_already = defined_relations.collect{|a| a.class}
    new_relations = []

    combination_class_relationships(rank_string).each do |r|
      new_relations.push( r.new(object_taxon_name: self) ) if !created_already.include?(r)
    end

    (new_relations + defined_relations).sort{|a,b|
      display_order.index(a.class.inverse_assignment_method) <=> display_order.index(b.class.inverse_assignment_method)
    }
  end

  def get_valid_taxon_name
    c = protonyms_by_rank
    return self if c.empty?
    c[c.keys.last].valid_taxon_name
  end

  def finest_protonym
    protonyms_by_rank.values.last
  end

  protected

  def to_node
    ::Utilities::Hierarchy::Node.new(
      id,
      cached_valid_taxon_name_id, # protonyms_by_rank.to_a.last.last.id,
      ['≡' + cached, cached_author_year, "[#{inferred_rank}]" ].compact.join(' '),
      nil,
      nil,
      nil,
      nil
    )
  end

  def reset_protonyms_by_rank
    @protonyms_by_rank = nil
  end

  def validate_absence_of_subject_relationships
    if TaxonNameRelationship.where(subject_taxon_name_id: self.id).where("type NOT LIKE 'TaxonNameRelationship::CurrentCombination'").any?
      errors.add(:base, 'This combination could not be used as a Subject in any TaxonNameRelationships.')
    end
  end

  def sv_redundant_verbatim_name
    if verbatim_name == full_name
      protonyms_by_rank.values.each do |t|
        return true unless t.has_latinized_classification?
      end
      soft_validations.add(:verbatim_name, 'Verbatim name is provided but not needed, it is the same as the computed value.')
    end
  end

  def sv_year_of_publication_matches_source
    source_year = source.nomenclature_year if source
    if year_of_publication && source_year
      soft_validations.add(:year_of_publication, 'The published date of the combination is not the same as provided by the original publication') if source_year != year_of_publication
    end
  end

  def sv_source_not_older_than_protonyms
    source_year = source.try(:nomenclature_year)
    target_year = earliest_protonym_year
    if source_year && target_year
      soft_validations.add(:base, "The publication date of combination (#{source_year}) is older than the original publication date of one of the name in the combination (#{target_year}") if source_year < target_year
    end
  end

  def sv_year_of_publication_not_older_than_protonyms
    if year_of_publication && earliest_protonym_year
      soft_validations.add(:year_of_publication,  "The publication date of combination (#{year_of_publication}) is older than the original publication date of one of the name in the combination (#{earliest_protonym_year}") if year_of_publication < earliest_protonym_year
    end
  end

  def sv_combination_duplicates
    duplicate = Combination.not_self(self).where(cached:, cached_author_year:, project_id: self.project_id)
    soft_validations.add(:base, 'Combination is a duplicate') unless duplicate.empty?
    if a = Combination.matching_protonyms(get_full_name, **protonym_ids_params)
      soft_validations.add(:base, "Combination exists as protonym(s) with matching original combination: #{a.all.pluck(:cached).join(', ')}.") if a.any?
    end
  end

  def sv_combination_linked_to_valid_name
    check = protonyms.first
    if parent_id && check && check.parent_id && parent_id != check.parent_id
      soft_validations.add(:base, "Combination #{cached_html_name_and_author_year} should have the same parent and rank with  #{check.cached_html_name_and_author_year}",
                           success_message: 'The parent was updated', failure_message:  'The parent was not updated')
    end
  end

  def sv_fix_combination_parent_update
    check = protonyms.first
    if parent_id && check && check.parent_id && parent_id != check.parent_id
      begin
        TaxonName.transaction do
          # update_column(:parent_id, check.parent_id) ## do not use this, it breaks the taxon_name_hierarchies
          parent_id = check.parent_id
          self.save
          return true
        end
      rescue
      end
    end
    false
  end

  def sv_cached_names
    is_cached = true
    is_cached = false if cached_author_year != get_author_and_year
    is_cached = false if cached_author != get_author

    n = get_full_name

    if is_cached && (
        cached_is_valid.nil? ||
        cached != n ||
        cached_html != get_full_name_html(n) ||
        cached_nomenclature_date != nomenclature_date)
      is_cached = false
    end

    soft_validations.add(
      :base, 'Cached values should be updated',
      success_message: 'Cached values were updated',
      failure_message:  'Failed to update cached values') if !is_cached
  end

  def sv_author_and_year_is_not_required
    if nomenclatural_code == :iczn && (!self.year_of_publication.nil? || !self.verbatim_author.nil?)
      soft_validations.add(
        :base, 'Verbatim author and year of publication are not required, they both derive from the source',
        success_message: 'Verbatim author and year were deleted',
        failure_message: 'Failed to delete verbatim author and year')
    end
  end

  def sv_fix_author_and_year_is_not_required
    self.update_columns(year_of_publication: nil, verbatim_author: nil)
    return true
  end

  def sv_fix_redundant_verbatim_name
    self.update_columns(verbatim_name: nil)
    return true
  end

  def set_parent
    names = protonyms
    write_attribute(:parent_id, names.first.parent.id) if names.count > 0 && names.first.parent
  end

  # The parent of a Combination is the parent of the highest ranked protonym in that Combination
  def parent_is_properly_set
    check = protonyms.first
    if parent && check && check.parent
      errors.add(:base, 'Parent is not highest ranked name.') if parent != check.parent
    end
  end

  def composition
    c = protonyms.count

    if c == 0
      errors.add(:base, 'Combination includes no names.')
      return
    end

    protonyms.each do |p|
      if !p.is_genus_or_species_rank?
        errors.add(:base, 'Combination includes one or more non-species or genus group names.')
        return
      end
    end

    # There are more than one protonyms, which seem to be valid elements
    p = protonyms.last
    errors.add(:base, 'Combination includes only one name and that is name is not a genus name.') if c < 2 && p.is_species_rank?
    errors.add(:base, 'Combination includes more than two genus group names.') if c > 2 && p.is_genus_rank?
  end

  def is_unique
    if a = Combination.match_exists?(verbatim_name, **protonym_ids_params)
      errors.add(:base, 'Combination exists.') if a.id != id
    end
  end

  def does_not_exist_as_original_combination
    if a = Combination.matching_protonyms(get_full_name, **protonym_ids_params)
      errors.add(:base, "Combination exists as protonym(s) with matching original combination: #{a.all.pluck(:cached).join(', ')}.") if a.any?
    end
  end

end
