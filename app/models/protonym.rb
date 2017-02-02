# Force the loading of TaxonNameRelationships in all worlds.  This allows us to edit without restarting in development. 
Dir[Rails.root.to_s + '/app/models/taxon_name_relationship/**/*.rb'].sort.each {|file| require_dependency file }

# A *monomial* TaxonName, a record implies a first usage. This follows Pyle's concept almost exactly.
#
# We inject a lot of relationship helper methods here, in this format. 
#   subject                      object
#   Aus      original_genus of   bus
#   aus      type_species of     Bus
#
#
class Protonym < TaxonName

  extend Protonym::SoftValidationExtensions::Klass
  include Protonym::SoftValidationExtensions::Instance

  alias_method :original_combination_source, :source

  FAMILY_GROUP_ENDINGS = %w{ini ina inae idae oidae odd ad oidea}

  validates_presence_of :name
  validates_presence_of :rank_class, message: 'is a required field' 
  validates_presence_of :name, message: 'is a required field' 
  
  validate :validate_rank_class_class,
    :validate_parent_rank_is_higher,
    :check_new_rank_class,
    :check_new_parent_class,
    :validate_source_type,
    :new_parent_taxon_name,
    :name_is_latinized,
    :name_is_valid_format

  after_create :create_otu,  if: 'self.also_create_otu'

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

  has_many :type_materials, class_name: 'TypeMaterial'

  TaxonNameRelationship.descendants.each do |d|
    if d.respond_to?(:assignment_method)
      if d.name.to_s =~ /TaxonNameRelationship::(Iczn|Icn|SourceClassifiedAs)/
        relationship = "#{d.assignment_method}_relationship".to_sym
        has_one relationship, class_name: d.name.to_s, foreign_key: :subject_taxon_name_id
        has_one d.assignment_method.to_sym, through: relationship, source: :object_taxon_name
      end

      if d.name.to_s =~ /TaxonNameRelationship::(OriginalCombination|Typification)/ # |SourceClassifiedAs
        relationships = "#{d.assignment_method}_relationships".to_sym
        has_many relationships, -> {
          where("taxon_name_relationships.type LIKE '#{d.name.to_s}%'")
        }, class_name: 'TaxonNameRelationship', foreign_key: :subject_taxon_name_id
        has_many d.assignment_method.to_s.pluralize.to_sym, through: relationships, source: :object_taxon_name
      end
    end

    if d.respond_to?(:inverse_assignment_method)
      if d.name.to_s =~ /TaxonNameRelationship::(Iczn|Icn|SourceClassifiedAs)/
        relationships = "#{d.inverse_assignment_method}_relationships".to_sym
        has_many relationships, -> {
          where("taxon_name_relationships.type LIKE '#{d.name.to_s}%'")
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

  # TODO: this is not really needed
  scope :named, -> (name) {where(name: name)}
  
  scope :with_name_in_array, -> (array) { where('name in (?)', array) }  

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
  scope :with_type_material_array, ->  (type_material_array) { joins('LEFT OUTER JOIN "type_materials" ON "type_materials"."protonym_id" = "taxon_names"."id"').where("type_materials.biological_object_id in (?) AND type_materials.type_type in ('holotype', 'neotype', 'lectotype', 'syntype', 'syntypes')", type_material_array) }
  scope :with_type_of_taxon_names, -> (type_id) { includes(:related_taxon_name_relationships).where("taxon_name_relationships.type LIKE 'TaxonNameRelationship::Typification%' AND taxon_name_relationships.subject_taxon_name_id = ?", type_id).references(:related_taxon_name_relationships) }
  scope :with_homonym_or_suppressed, -> { includes(:taxon_name_relationships).where("taxon_name_relationships.type LIKE 'TaxonNameRelationship::Iczn::Invalidating::Homonym%' OR taxon_name_relationships.type LIKE 'TaxonNameRelationship::Iczn::Invalidating::Suppression::Total'").references(:taxon_name_relationships) }
  scope :without_homonym_or_suppressed, -> { where("id not in (SELECT subject_taxon_name_id FROM taxon_name_relationships WHERE taxon_name_relationships.type LIKE 'TaxonNameRelationship::Iczn::Invalidating::Homonym%' OR taxon_name_relationships.type LIKE 'TaxonNameRelationship::Iczn::Invalidating::Suppression::Total')") }
  scope :with_primary_homonym, -> (primary_homonym) {where(cached_primary_homonym: primary_homonym)}
  scope :with_primary_homonym_alternative_spelling, -> (primary_homonym_alternative_spelling) {where(cached_primary_homonym_alternative_spelling: primary_homonym_alternative_spelling)}
  scope :with_secondary_homonym, -> (secondary_homonym) {where(cached_secondary_homonym: secondary_homonym)}
  scope :with_secondary_homonym_alternative_spelling, -> (secondary_homonym_alternative_spelling) {where(cached_secondary_homonym_alternative_spelling: secondary_homonym_alternative_spelling)}

  # TODO, move to IsData or IsProjectData
  scope :with_project, -> (project_id) {where(project_id: project_id)}

  # TODO: isn't this the way to do it now?
  # scope :that_is_valid, -> {where('taxon_names.id != taxon_names.cached_valid_taxon_name_id') }

  scope :that_is_valid, -> {
    joins('LEFT OUTER JOIN taxon_name_relationships tnr ON taxon_names.id = tnr.subject_taxon_name_id').
    where("taxon_names.id NOT IN (SELECT subject_taxon_name_id FROM taxon_name_relationships WHERE type ILIKE 'TaxonNameRelationship::Iczn::Invalidating%' OR type ILIKE 'TaxonNameRelationship::Icn::Unaccepting%')")
  }

  # @return [Array of Strings]
  #   genera where the species was placed
  def all_generic_placements
    valid_name = get_valid_taxon_name
    return nil unless valid_name.rank_string !=~/Species/
    descendants_and_self = valid_name.descendants + [self] + self.combinations
    relationships        = TaxonNameRelationship.where_object_in_taxon_names(descendants_and_self).with_two_type_bases('TaxonNameRelationship::OriginalCombination::OriginalGenus', 'TaxonNameRelationship::Combination::Genus')
    (relationships.collect { |r| r.subject_taxon_name.name } + [self.ancestor_at_rank('genus').name]).uniq
  end

  # @return [boolean]
  def is_fossil?
    taxon_name_classifications.with_type_contains('::Fossil').any? 
  end

  def list_of_coordinated_names
    list = []
    if self.rank_string
      r = self.iczn_set_as_incorrect_original_spelling_of_relationship
      if r.blank?
        search_rank = NomenclaturalRank::Iczn.group_base(self.rank_string)
        if !!search_rank
          if search_rank =~ /Family/
            z = Protonym.family_group_base(self.name)
            search_name = z.nil? ? nil : Protonym::FAMILY_GROUP_ENDINGS.collect{|i| z+i}
          else
            search_name = self.name
          end
        else
          search_name = nil
        end

        unless search_name.nil?
          list = Protonym.ancestors_and_descendants_of(self).not_self(self).
            with_rank_class_including(search_rank).
            with_name_in_array(search_name).
            as_subject_without_taxon_name_relationship_base('TaxonNameRelationship::Iczn::Invalidating::Synonym') 
        else
          list = []
        end
      else
        list = [r.object_taxon_name]
      end
    end
    return list
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

  # @return [String, nil]
  #   a string, without parenthesis, that includes author and year
  def get_author_and_year
    case self.rank_class.try(:nomenclatural_code)
      when :iczn
        ay = iczn_author_and_year
      when :icn
        ay = icn_author_and_year
      else
        ay = ([self.author_string] + [self.year_integer]).compact.join(' ')
    end
    ay.blank? ? nil : ay
  end

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

  def self.family_group_base(name_string)
    name_string.match(/(^.*)(ini|ina|inae|idae|oidae|odd|ad|oidea)$/)
    $1 || name_string
  end

  def self.family_group_name_at_rank(name_string, rank_string)
    if name_string == family_group_base(name_string)
      name_string
    else
      family_group_base(name_string) + Ranks.lookup(:iczn, rank_string).constantize.try(:valid_name_ending).to_s
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
    return true if taxon1_types.empty? && taxon2_types.empty? # both are empty !! If they are both empty then they don't have the same type, the have no types  !!
    return false if taxon1_types.empty? || taxon2_types.empty? # one is empty

    taxon1_types.map(&:biological_object_id) == taxon2_types.map(&:biological_object_id) # collect{|i| i.biological_object_id} 
  end

  # return [Array of TaxonNameRelationship]
  #   classes that are applicable to this name, as deterimined by Rank
  def original_combination_class_relationships
    relations = []
    TaxonNameRelationship::OriginalCombination.descendants.each do |r|
      relations.push(r) if r.valid_object_ranks.include?(self.rank_string)
    end
    relations
  end

  def original_combination_relationships_and_stubs
    # TODO: figure out where to really put this, likely in one big sort
    display_order = [
      :original_genus, :original_subgenus, :original_species, :original_subspecies, :original_variety, :original_form
    ]

    defined_relations = self.original_combination_relationships.all
    created_already = defined_relations.collect{|a| a.class}
    new_relations = [] 

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
    if type == 'Protonym'
      taxon_name_classifications.each do |tc| # ! find_each
        return true if TaxonName::EXCEPTED_FORM_TAXON_NAME_CLASSIFICATIONS.include?(tc.type)
      end
    end
    false
  end

  def is_latin?
    !NOT_LATIN.match(name) || has_latinized_exceptions?
  end

  def is_species_rank?
    SPECIES_RANK_NAMES.include?(rank_string)
  end

  def is_genus_rank?
    GENUS_RANK_NAMES.include?(rank_string)
  end

  def is_family_rank?
    FAMILY_RANK_NAMES.include?(rank_string)
  end

  # TODO: Why protected?  What does it do?
  def genus_suggested_gender
    return nil unless rank_string =~/Genus/
    TAXON_NAME_CLASSIFICATION_GENDER_CLASSES.each do |g|
      g.possible_genus_endings.each do |e|
        return g.name.demodulize.underscore.humanize.downcase if self.name =~ /^[a-zA-Z]*#{e}$/
      end
    end
    nil
  end

  # TODO: why protected?
  def species_questionable_ending(g, n)
    return nil unless rank_string =~ /Species/
    g.questionable_species_endings.each do |e|
      return e if n =~ /^[a-z]*#{e}$/
    end
    nil
  end

  def reduce_list_of_synonyms(list)
    return [] if list.empty?
    list1 = list.select{|s| s.id == s.lowest_rank_coordinated_taxon.id}
    unless list1.empty?
      date1 = self.nomenclature_date
      unless date1.nil?
        list1.reject!{|s| date1 < (s.year_of_publication ? s.nomenclature_date : Time.utc(1))}
      end
    end
    list1
  end

  protected

  def name_is_latinized
    errors.add(:name, 'Name must be latinized, no digits or spaces allowed') if !is_latin?
  end

  def name_is_valid_format
    rank_class.validate_name_format(self) if rank_class && rank_class.respond_to?(:validate_name_format) && !has_latinized_exceptions?
  end

  def create_otu
    Otu.create(by: self.creator, project: self.project, taxon_name_id: self.id)
  end

  #region Validation

  def new_parent_taxon_name
    r = self.iczn_uncertain_placement_relationship
    unless r.blank?
      if self.parent != r.object_taxon_name
        errors.add(:parent_id, "Taxon has a relationship 'incertae sedis' - delete the relationship before changing the parent")
      end
    end
  end

  def validate_rank_class_class
    errors.add(:rank_class, 'Rank not found') unless RANKS.include?(rank_string)
  end 

  #endregion


  def set_cached_names
    super 
    if self.errors.empty? && !self.no_cached

      # set_cached_higher_classification
      set_primary_homonym
      set_primary_homonym_alternative_spelling

      if rank_string =~ /Species/
        set_secondary_homonym
        set_secondary_homonym_alternative_spelling
      end
      set_cached_misspelling
    end
  end

  def set_cached
    self.cached = get_full_name
  end

  def set_cached_html
    self.cached_html = get_full_name_html
  end

  def set_cached_misspelling
    self.cached_misspelling = get_cached_misspelling
  end

  # Deprecated
  # def set_cached_higher_classification
  #   self.cached_higher_classification = get_higher_classification
  # end

  def set_primary_homonym
    self.cached_primary_homonym = get_genus_species(:original, :self)
  end

  def set_primary_homonym_alternative_spelling
    self.cached_primary_homonym_alternative_spelling = get_genus_species(:original, :alternative)
  end

  def set_secondary_homonym
    self.cached_secondary_homonym = get_genus_species(:current, :self)
  end

  def set_secondary_homonym_alternative_spelling
    self.cached_secondary_homonym_alternative_spelling = get_genus_species(:current, :alternative)
  end

  def set_cached_original_combination
    self.cached_original_combination = get_original_combination
  end

  def set_cached_valid_taxon_name_id
    begin
      TaxonName.transaction do
        self.update_column(:cached_valid_taxon_name_id, self.get_valid_taxon_name.id)
        #self.valid_taxon_name = get_valid_taxon_name
      end
    rescue
    end
  end

  #endregion

end

