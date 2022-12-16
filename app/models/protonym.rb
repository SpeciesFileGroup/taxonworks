# Nested ness of this should get all the relationships?
require_dependency Rails.root.to_s + '/app/models/taxon_name_relationship.rb'


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

  # @return [Boolean]
  #   memoize `#is_avaiable?`
  attr_reader :is_available

  alias_method :original_combination_source, :source

  FAMILY_GROUP_ENDINGS = %w{ini ina inae idae oidae odd ad oidea}.freeze

  validates_presence_of :name, message: 'is a required field'
  validates_presence_of :rank_class, message: 'is a required field'

  validate :validate_rank_class_class,
    :validate_same_nomenclatural_code,
    :validate_parent_rank_is_higher,
    :validate_child_rank_is_equal_or_lower,
    :check_new_rank_class,
    :check_new_parent_class,
    :validate_source_type,
    :new_parent_taxon_name,
    :name_is_latinized,
    :name_is_valid_format,
    :verbatim_author_without_digits,
    :verbatim_author_with_closed_parens_when_present

  after_create :create_otu, if: -> {self.also_create_otu}

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

  has_many :combination_relationships, -> {
    where("taxon_name_relationships.type LIKE 'TaxonNameRelationship::Combination::%'")
  }, class_name: 'TaxonNameRelationship', foreign_key: :subject_taxon_name_id

  has_many :combinations, through: :combination_relationships, source: :object_taxon_name

  has_many :type_materials, class_name: 'TypeMaterial', inverse_of: :protonym

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
  scope :named, -> (name) {where(name: name)}

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
  scope :with_project, -> (project_id) {where(project_id: project_id)}

  scope :is_species_group, -> { where("rank_class ILIKE '%speciesgroup%'") }
  scope :is_genus_group, -> { where("rank_class ILIKE '%genusgroup%'") }
  scope :is_family_group, -> { where("rank_class ILIKE '%family%'") }

  scope :is_species_or_genus_group, -> {  where("rank_class ILIKE '%speciesgroup%' OR rank_class ILIKE '%genusgroup%'")   }

  scope :is_original_name, -> { where("cached_author_year NOT ILIKE '(%'") }
  scope :is_not_original_name, -> { where("cached_author_year ILIKE '(%'") }

  # Protonym.order_by_rank(RANKS) or Protonym.order_by_rank(ICZN)
  scope :order_by_rank, -> (code) {order(Arel.sql("position(taxon_names.rank_class in '#{code}')"))}

  # @return [Protonym]
  #   a name ready to become the root
  def self.stub_root(project_id: nil, by: nil)
    Protonym.new(name: 'Root', rank_class: 'NomenclaturalRank', parent_id: nil, project_id: project_id, by: by)
  end

  def self.family_group_base(name_string)
    name_string.match(/(^.*)(ini|ina|inae|idae|oidae|odd|ad|oidea)$/)
    $1 || name_string
  end

  def self.family_group_name_at_rank(name_string, rank_string)
    if name_string == Protonym.family_group_base(name_string)
      name_string
    else
      Protonym.family_group_base(name_string) + Ranks.lookup(:iczn, rank_string).constantize.try(:valid_name_ending).to_s
    end
  end

  # @param rank ['speciesgroup' or 'genusgroup' or 'family']
  #    scope to names used in taxon determinations
  def self.names_at_rank_group_for_collection_objects(rank = 'speciesgroup')
    h = ::TaxonNameHierarchy.arel_table
    t = ::TaxonName.arel_table
    t1 = ::TaxonName.arel_table.alias('tndet')
    d = ::TaxonDetermination.arel_table
    o = ::Otu.arel_table

    q = t.join(h, Arel::Nodes::InnerJoin).on(
      t[:id].eq(h[:ancestor_id])
    ).join(t1, Arel::Nodes::InnerJoin).on(
      h[:descendant_id].eq(t1[:id])
    ).join(o, Arel::Nodes::InnerJoin).on(
      t1[:id].eq(o[:id])
    ).join(d, Arel::Nodes::InnerJoin).on(
      o[:id].eq(d[:otu_id])
    )

    joins(q.join_sources).where(t[:rank_class].matches('%' + rank + '%').to_sql).distinct
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
  def all_generic_placements
    valid_name = get_valid_taxon_name
    return nil unless valid_name.rank_string !=~/Species/
    descendants_and_self = valid_name.descendants + [self] + self.combinations
    relationships = TaxonNameRelationship.where_object_in_taxon_names(descendants_and_self).with_two_type_bases('TaxonNameRelationship::OriginalCombination::OriginalGenus', 'TaxonNameRelationship::Combination::Genus')
    (relationships.collect { |r| r.subject_taxon_name.name } + [self.ancestor_at_rank('genus').try(:name)]).uniq
  end

  def list_of_coordinated_names
    list = []
    if self.rank_string
      r = self.iczn_set_as_incorrect_original_spelling_of_relationship
      if r.blank?
        search_rank = NomenclaturalRank::Iczn.group_base(rank_string)
        if !!search_rank
          if search_rank =~ /Family/
            if self.cached_is_valid
              z = Protonym.family_group_base(self.name)
              search_name = z.nil? ? nil : Protonym::FAMILY_GROUP_ENDINGS.collect{|i| z+i}
            else
              search_name = nil
            end
          else
            search_name = self.name
          end
        else
          search_name = nil
        end

        #        r = TaxonNameRelationship.where_subject_is_taxon_name(self).with_type_array(TAXON_NAME_RELATIONSHIP_NAMES_MISSPELLING)
        #        if !search_name.nil? && r.empty?
        if !search_name.nil? && is_available?
          list = Protonym
            .ancestors_and_descendants_of(self)
            .with_rank_class_including(search_rank)
            .where(name: search_name)
            .not_self(self)
            .that_is_valid
        else
          list = []
        end
      else
        list = [r.object_taxon_name]
      end
    end
    return list
  end

  def is_available?(refresh = false)
    if !refresh
      @is_available ||= !has_misspelling_relationship? && !name_is_misapplied? && !classification_invalid_or_unavailable?
    else
      @is_available = !has_misspelling_relationship? && !name_is_misapplied? && !classification_invalid_or_unavailable?
    end
    @is_available
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

  # This method is currently only used for setting cached_primary_homonym
  # @return [nil, false, String]
  #   !! Why both?
  def get_genus_species(genus_option, self_option)
    return nil if rank_class.nil?
    genus = nil
    name1 = nil

    if is_species_rank? # self.rank_string =~ /Species/
      if genus_option == :original
        genus = original_genus
      elsif genus_option == :current
        genus = ancestor_at_rank('genus')
      else
        return false
      end

      genus = genus.name unless genus.blank?
      return nil if genus.blank?
    end

    if self_option == :self
      name1 = name
    elsif self_option == :alternative
      name1 = name_with_alternative_spelling
    end

    return nil if genus.nil? && name1.nil? # <- hitting this because Genus is never set
    [genus, name1].compact.join(' ')
    # (genus.to_s + ' ' + name1.to_s).squish
  end

  # TODO, make back half of this raw SQL
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
    Protonym.ancestors_and_descendants_of(self).not_self(self).to_a
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
          if !r2.valid_name_ending.blank? && child_string.end_with?(r2.valid_name_ending) && r2.typical_use && RANKS.index(r1) > RANKS.index(parent_rank)
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

  # temporary method to get a number of taxa described by year
  def number_of_taxa_by_year
    file_name = '/tmp/taxa_by_year' + '_' + Time.now.to_i.to_s + '.csv'
    a = {}
    descendants.find_each do |z|
      year = z.year_integer
      year = 0 if year.nil?
      a[year] = {:valid => 0, :synonyms => 0} unless a[year]
      if z.rank_string == 'NomenclaturalRank::Iczn::SpeciesGroup::Species'
        if z.cached_is_valid
          a[year][:valid] = a[year][:valid] += 1
        elsif TaxonNameRelationship.where_subject_is_taxon_name(z.id).with_type_array(::TAXON_NAME_RELATIONSHIP_NAMES_SYNONYM).any?
          a[year][:synonyms] = a[year][:synonyms] += 1
        end
      end
    end
    for i in 1758..Time.now.year do
      a[i] = {:valid => 0, :synonyms => 0} unless a[i]
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

  # !! TODO: Should not be possible- fix the incoming data
  # @return [Boolean]
  #    true if taxon2 has the same primary type
  def has_same_primary_type(taxon2)
    return true unless rank_class.parent.to_s =~ /Species/

    taxon1_types = get_primary_type.sort_by{|i| i.id}
    taxon2_types = taxon2.get_primary_type.sort_by{|i| i.id}
    return true if taxon1_types.empty? && taxon2_types.empty? # both are empty !! If they are both empty then they don't have the same type, the have no types  !!
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
    created_already   = defined_relations.collect{|a| a.class}
    new_relations     = []

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

    return true if is_family_rank? && !(taxon_name_relationships.collect{|i| i.type} & ::TAXON_NAME_RELATIONSHIP_NAMES_SYNONYM).empty?
    return true unless (taxon_name_classifications.collect{|i| i.type} & ::EXCEPTED_FORM_TAXON_NAME_CLASSIFICATIONS).empty?
    return true unless (taxon_name_relationships.collect{|i| i.type} & ::TAXON_NAME_RELATIONSHIP_NAMES_MISSPELLING).empty?
    false
  end

  def is_latin?
    !NOT_LATIN.match(name) || has_latinized_exceptions?
  end

  # @return [Boolean]
  #   whether this name has one of the TaxonNameRelationships which justify wrong form of the name
  def has_misspelling_relationship?
    taxon_name_relationships.with_type_array(TAXON_NAME_RELATIONSHIP_NAMES_MISSPELLING).any?
  end

  # Same as is_original_name?!
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
  #   could also be determined by parens in cached_author year
  def is_original_name?
    cached_author_year =~ /\(/ ? false : true
  end

  def reduce_list_of_synonyms(list)
    return [] if list.empty?
    list1 = list.select{|s| s.id == s.lowest_rank_coordinated_taxon.id}
    list1.reject!{|s| self.cached_valid_taxon_name_id == s.cached_valid_taxon_name_id} unless list1.empty?
    unless list1.empty?
      date1 = self.nomenclature_date
      unless date1.nil?
        list1.reject!{|s| date1 < (s.year_of_publication ? s.nomenclature_date : Time.utc(1))}
      end
    end
    list1
  end

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

  def predict_three_forms
    exception = LATIN_ADJECTIVES[name]

    return exception unless exception.nil?
    m_name, f_name, n_name = nil, nil, nil
    case name
    when /(color|coloris)$/
      m_name, f_name, n_name = name, name, name
    when /is$/
      m_name, f_name, n_name = name, name, name[0..-3] + 'e'
    when /e$/
      m_name, f_name, n_name = name[0..-2] + 'is', name[0..-2] + 'is', name
    when /us$/
      m_name, f_name, n_name = name, name[0..-3] + 'a', name[0..-3] + 'um'
    when /er$/
      m_name, f_name, n_name = name, name[0..-3] + 'ra', name[0..-3] + 'rum'
    when /(ferum|gerum)$/
      m_name, f_name, n_name = name[0..-3], name[0..-3] + 'a', name
    when /(gera|fera)$/
      m_name, f_name, n_name = name[0..-2], name, name[0..-2] + 'um'
    when /(brum|frum|grum)$/
      m_name, f_name, n_name = name[0..-4] + 'er', name[0..-3] + 'a', name
    when /(bra|gra|fra)$/
      m_name, f_name, n_name = name[0..-3] + 'er', name, name[0..-2] + 'um'
    when /(um)$/
      m_name, f_name, n_name = name[0..-3] + 'us', name[0..-3] + 'a', name
    when /a$/
      m_name, f_name, n_name = name[0..-2] + 'us', name, name[0..-2] + 'um'
    when /(nor|ior|jor)$/
      m_name, f_name, n_name = name, name, name[0..-3] + 'us'
    else
      m_name, f_name, n_name = name, name, name
    end
    {masculine_name: m_name, feminine_name: f_name, neuter_name: n_name}
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

    if !relationship_housekeeping.empty?
      combination.protonyms_by_rank.each do |rank, p|
        r = send("original_#{rank}_relationship")
        r.write_attributes(relationship_housekeeping)
      end
    end
    true
  end

  def get_original_combination
    return verbatim_name if !GENUS_AND_SPECIES_RANK_NAMES.include?(rank_string) && !verbatim_name.nil?
    e = original_combination_elements
    return nil if e.none?

    # Weird, why?
    # DD: in ICVCN the species name is "Potato spindle tuber viroid", the genus name is only used for classification...
    #
    # @proceps: then we should exclude or alter elements before we get to this point, not here, so that the renderer still works, exceptions at this point are bad
    # and this didn't do what you think it did, it's was returning an Array of two things
    return e[:species][1] if rank_class.to_s =~ /Icvcn/

    p = TaxonName::COMBINATION_ELEMENTS.inject([]){|ary, r| ary.push(e[r]) }

    s = p.flatten.compact.join(' ')
    s.blank? ? nil : s
  end

  # @return [Hash]
  #
  # {
  #  genus: ["", 'Aus' ],
  #  ...
  #  form: ['frm', 'aus']
  # }
  #
  def original_combination_elements
    elements = { }
    return elements if rank.blank?

    this_rank = rank.to_sym

    # Why this?
    #   We need to apply gender to "internal" names for original combinations, everything
    #   but the last name
    # DD: if we have subspecies, the species name should be used not in the original form,
    # but the form correlated with the present genus gender
    # TODO: get SQL based ordering for original_combination_relationships, hard coded

    # order the relationships
    r = original_combination_relationships.reload.sort{|a,b| ORIGINAL_COMBINATION_RANKS.index(a.type) <=> ORIGINAL_COMBINATION_RANKS.index(b.type) }

    # get gender from first
    gender = original_genus&.gender_name # r.first.subject_taxon_name.gender_name

    # Apply gender to everything but the last
    total = r.count - 1
    r.each_with_index do |j, i|
      if j.type =~ /enus/ || i == total
        g = nil
      else
        g = gender
      end
      elements.merge! j.combination_name(g) # this is like '{genus: [nil, 'Aus']}
    end

    # what is point of this? Do we get around this check by requiring self relationships? (species aus has species relationship to self)
    # DD: we do not require it, it is optional
    if !r.empty? && r.collect{|i| i.subject_taxon_name}.last.lowest_rank_coordinated_taxon.id != lowest_rank_coordinated_taxon.id
      if elements[this_rank].nil?
        elements[this_rank] = [nil, original_name]
      end
    end

    if elements.any?
      if !elements[:genus] && !not_binominal?
        if original_genus
          elements[:genus] = [nil, "[#{original_genus&.name}]"]
        else
          elements[:genus] = [nil, '[GENUS NOT SPECIFIED]']
        end
      end
      # If there is no :species, but some species group, add element
      elements[:species] = [nil, '[SPECIES NOT SPECIFIED]'] if !elements[:species] && ( [:subspecies, :variety, :form] & elements.keys ).size > 0
    end

    elements
  end

  # @return [[rank_name, name], nil]
  #   Used in ColDP export
  def original_combination_infraspecific_element(elements = nil)
    elements ||= original_combination_elements

    # TODO: consider plants/other codes?
    [:form, :variety, :subspecies].each do |r|
      return [r.to_s, elements[r].last] if elements[r]
    end
    nil
  end

  # @return [String, nil]
  #    a monominal, as originally rendered, with parens if subgenus
  def original_name
    n = verbatim_name.nil? ? name_with_misspelling(nil) : verbatim_name
    n = "(#{n})" if n && rank_name == 'subgenus'
    n
  end

  def get_original_combination_html
    return  "\"<i>Candidatus</i> #{get_original_combination}\"" if is_candidatus?
    v = get_original_combination
    if !v.blank? && is_hybrid?
      w = v.split(' ')
      w[-1] = ('×' + w[-1]).gsub('×(', '(×').gsub(') [sic]', ' [sic])').gsub(') (sic)', ' (sic))')
      v = w.join(' ')
    end
    v = v.gsub(') [sic]', ' [sic])').gsub(') (sic)', ' (sic))') if !v.blank?

    v = Utilities::Italicize.taxon_name(v) if is_genus_or_species_rank?
    v = '† ' + v if !v.blank? && is_fossil?
    v
  end

  def update_cached_original_combinations
    update_columns(
      cached_original_combination: get_original_combination,
      cached_original_combination_html: get_original_combination_html,
      cached_primary_homonym: get_genus_species(:original, :self),
      cached_primary_homonym_alternative_spelling: get_genus_species(:original, :alternative))
  end

  def set_cached_species_homonym
    update_columns(
      cached_secondary_homonym: get_genus_species(:current, :self),
      cached_secondary_homonym_alternative_spelling: get_genus_species(:current, :alternative)
    )
  end

  def set_cached_names_for_dependants
    dependants = []
    related_through_original_combination_relationships = []
    combination_relationships = []

    TaxonName.transaction_with_retry do
      if is_genus_or_species_rank?
        dependants = Protonym.unscoped.descendants_of(self).to_a
        related_through_original_combination_relationships = TaxonNameRelationship.where_subject_is_taxon_name(self).with_type_contains('OriginalCombination')
        combination_relationships = TaxonNameRelationship.where_subject_is_taxon_name(self).with_type_contains('::Combination')
      end

     #  dependants.push(self) # combination does hit here

      # Combination can hit here
      classified_as_relationships = TaxonNameRelationship.where_object_is_taxon_name(self).with_type_contains('SourceClassifiedAs')

      dependants.each do |i|
        n = i.get_full_name
        columns_to_update = {
          cached: n,
          cached_html: i.get_full_name_html(n),
          cached_author_year: i.get_author_and_year,
          cached_nomenclature_date: i.nomenclature_date
        }

        if i.is_species_rank?
          columns_to_update[:cached_secondary_homonym] = i.get_genus_species(:current, :self)
          columns_to_update[:cached_secondary_homonym_alternative_spelling] = i.get_genus_species(:current, :alternative)
        end

        i.update_columns(columns_to_update)
      end

      related_through_original_combination_relationships.collect{|i| i.object_taxon_name}.uniq.each do |i|
        i.update_cached_original_combinations
      end

      # Update values in Combinations
      combination_relationships.collect{|i| i.object_taxon_name}.uniq.each do |j|
        n = j.get_full_name
        j.update_columns(
          cached: n,
          cached_html: j.get_full_name_html(n),
          cached_author_year: j.get_author_and_year,
          cached_nomenclature_date: j.nomenclature_date)
      end

      classified_as_relationships.collect{|i| i.subject_taxon_name}.uniq.each do |i|
        i.update_column(:cached_classified_as, i.get_cached_classified_as)
      end

      classified_as_relationships.collect{|i| i.object_taxon_name}.uniq.each do |i|
        n = i.get_full_name
        i.update_columns(
          cached: n,
          cached_html: i.get_full_name_html(n),
          cached_author_year: i.get_author_and_year,
          cached_nomenclature_date: i.nomenclature_date)
      end

      misspelling_relationships = TaxonNameRelationship.where_object_is_taxon_name(self).with_type_array(TAXON_NAME_RELATIONSHIP_NAMES_MISSPELLING_AND_MISAPPLICATION)
      misspelling_relationships.collect{|i| i.subject_taxon_name}.uniq.each do |i|
        i.update_columns(cached_author_year: i.get_author_and_year,
                         cached_nomenclature_date: i.nomenclature_date)
      end
    end
  end

  # @return [boolean]
  def nominotypical_sub_of?(protonym)
    is_genus_or_species_rank? && parent == protonym && parent.name == protonym.name
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

  def create_otu
    Otu.create(by: self.creator, project: self.project, taxon_name_id: self.id)
  end

  def new_parent_taxon_name
    r = self.iczn_uncertain_placement_relationship
    unless r.blank?
      if self.parent != r.object_taxon_name
        errors.add(:parent_id, "Taxon has an 'Incertae sedis' relationship, which prevent the parent modifications, change the relationship to 'Source classified as' before updating the parent")
      end
    end
  end

  def validate_rank_class_class
    errors.add(:rank_class, 'Rank not found') unless RANKS.include?(rank_string)
  end

  def validate_child_rank_is_equal_or_lower
    if parent && !rank_class.blank? && rank_string != 'NomenclaturalRank'
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
    if parent && !rank_class.blank? && rank_string != 'NomenclaturalRank'
      if RANKS.index(rank_string) <= RANKS.index(parent.rank_string)
        errors.add(:parent_id, "The parent rank (#{parent.rank_class.rank_name}) is not higher than the rank (#{rank_name}) of this taxon")
      end
    end
  end

  def validate_same_nomenclatural_code
    if parent&.nomenclatural_code && nomenclatural_code != parent.nomenclatural_code
      errors.add(:rank_class, "The parent nomenclatural code (#{parent.nomenclatural_code.to_s.upcase}) is not matching to the nomenclatural code (#{nomenclatural_code.to_s.upcase}) of this taxon")
    end
  end

  # This is a *very* expensive soft validation, it should be fragemented into individual parts likely
  # It should also not be necessary by default our code should be good enough to handle these
  # issues in the long run.
  # DD: rules for cached tend to evolve, what was good in the past, may not be true today
  def sv_cached_names # this cannot be moved to soft_validation_extensions
  is_cached = true
  is_cached = false if cached_author_year != get_author_and_year

  if is_cached && (
      cached_valid_taxon_name_id != get_valid_taxon_name.id ||
      cached_is_valid != !unavailable_or_invalid? || # Do not change this, we want the calculated value.
      cached_html != get_full_name_html ||
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
    failure_message:  'Failed to update cached values') if !is_cached
  end

  def set_cached
    super
    set_cached_names_for_dependants
    set_cached_original_combination
    set_cached_original_combination_html
    set_cached_homonymy
    set_cached_species_homonym if is_species_rank?
    set_cached_misspelling
  end

  def set_cached_homonymy
    update_columns(
      cached_primary_homonym: get_genus_species(:original, :self),
      cached_primary_homonym_alternative_spelling: get_genus_species(:original, :alternative)
    )
  end

  # all three in one update here
  def set_cached_misspelling
    update_column(:cached_misspelling, get_cached_misspelling)
  end

  def set_cached_original_combination
    update_column(:cached_original_combination, get_original_combination)
  end

  def set_cached_original_combination_html
    update_column(:cached_original_combination_html, get_original_combination_html)
  end
end

