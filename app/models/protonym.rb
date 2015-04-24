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

  alias_method :original_combination_source, :source

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
      if d.name.to_s =~ /TaxonNameRelationship::(Iczn|Icn)/
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
      if d.name.to_s =~ /TaxonNameRelationship::(Iczn|Icn)/
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

  scope :that_is_valid, -> {
    joins('LEFT OUTER JOIN taxon_name_relationships tnr ON taxon_names.id = tnr.subject_taxon_name_id').
    where("taxon_names.id NOT IN (SELECT subject_taxon_name_id FROM taxon_name_relationships WHERE type LIKE 'TaxonNameRelationship::Iczn::Invalidating%' OR type LIKE 'TaxonNameRelationship::Icn::Unaccepting%')")
  }


  soft_validate(:sv_validate_parent_rank, set: :validate_parent_rank)
  soft_validate(:sv_missing_relationships, set: :missing_relationships)
  soft_validate(:sv_missing_classifications, set: :missing_classifications)
  soft_validate(:sv_species_gender_agreement, set: :species_gender_agreement)
  soft_validate(:sv_type_placement, set: :type_placement)
  soft_validate(:sv_primary_types, set: :primary_types)
  soft_validate(:sv_validate_coordinated_names, set: :validate_coordinated_names)
  soft_validate(:sv_single_sub_taxon, set: :single_sub_taxon)
  soft_validate(:sv_parent_priority, set: :parent_priority)
  soft_validate(:sv_homotypic_synonyms, set: :homotypic_synonyms)
  soft_validate(:sv_potential_homonyms, set: :potential_homonyms)
  soft_validate(:sv_source_not_older_then_description, set: :dates)
  soft_validate(:sv_original_combination_relationships, set: :original_combination_relationships)

  before_validation :check_format_of_name,
    :validate_rank_class_class,
    :validate_parent_rank_is_higher,
    :check_new_rank_class,
    :check_new_parent_class,
    :validate_source_type,
    :new_parent_taxon_name,
    :name_is_latinized

  # @return [Array of Strings]
  #   genera where the species was placed
  def all_generic_placements
    valid_name = self.get_valid_taxon_name
    return nil unless valid_name.rank_string !=~/Species/
    descendants_and_self = valid_name.descendants + [self] + self.combinations
    relationships        = TaxonNameRelationship.where_object_in_taxon_names(descendants_and_self).with_two_type_bases('TaxonNameRelationship::OriginalCombination::OriginalGenus', 'TaxonNameRelationship::Combination::Genus')
    relationships.collect { |r| r.subject_taxon_name.name } + [self.ancestor_at_rank('genus').name]
  end

  # TODO: make a constant somewhere, it's def not a instance method

  FAMILY_GROUP_ENDINGS = %w{ini ina inae idae oidae odd ad oidea}

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
          list = Protonym.ancestors_and_descendants_of(self).
            with_rank_class_including(search_rank).
            with_name_in_array(search_name).
            as_subject_without_taxon_name_relationship_base('TaxonNameRelationship::Iczn::Invalidating::Synonym') # <- use this
          #list1 = self.ancestors_and_descendants                               # scope with parens
          #list1 = list1.select{|i| /#{search_rank}.*/.match(i.rank_class.to_s)} # scope on rank_class
          #list1 = list1.select{|i| /#{search_name}/.match(i.name)}              # scope on named
          #list1 = list1.reject{|i| i.unavailable_or_invalid?}                   # scope with join on taxon_name_relationships and where > 1 on them
        else
          list = []
        end
      else
        list = [r.object_taxon_name]
      end
    end
    return list
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

  def ancestors_and_descendants
    Protonym.ancestors_and_descendants_of(self).to_a
  end

  def self.family_group_base(name_string)
    name_string.match(/(^.*)(ini|ina|inae|idae|oidae|odd|ad|oidea)/)
    $1
  end

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

  def has_same_primary_type(taxon2) # two taxa has the same primary type speciemens
    return true unless self.rank_class.parent.to_s =~ /Species/
    taxon1_types = self.get_primary_type.sort_by{|i| i.id}
    taxon2_types = taxon2.get_primary_type.sort_by{|i| i.id}
    return true if taxon1_types.empty? && taxon2_types.empty? # both are empty
    return false if taxon1_types.empty? || taxon2_types.empty? # one is empty

    if taxon1_types.collect{|i| i.biological_object_id} == taxon2_types.collect{|i| i.biological_object_id}
      true
    else
      false
    end
  end

  # return [Array of TaxonNameRelationship]
  #   classes that are applicable to this name, as deterimned by Rank
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

  protected

  #region Validation

  def new_parent_taxon_name
    r = self.iczn_uncertain_placement_relationship
    unless r.blank?
      if self.parent != r.object_taxon_name
        errors.add(:parent_id, "Taxon has a relationship 'incertae sedis' - delete the relationship before changing the parent")
      end
    end
  end

  def name_is_latinized
    if name =~ /[^a-zA-Z|\-]/
      errors.add(:name, 'must be latinized, no digits or spaces allowed')
    end
  end

  #endregion

  #region Soft validation

  def sv_source_not_older_then_description
    if self.source && self.year_of_publication
      soft_validations.add(:source_id, 'The year of publication and the year of reference do not match') if self.source.year != self.year_of_publication
    end
  end

  def sv_validate_parent_rank
    if self.rank_class
      if self.rank_class.to_s == 'NomenclaturalRank' || self.parent.rank_class.to_s == 'NomenclaturalRank' || !!self.iczn_uncertain_placement_relationship
        true
      elsif !self.rank_class.valid_parents.include?(self.parent.rank_class.to_s)
        soft_validations.add(:rank_class, "The rank #{self.rank_class.rank_name} is not compatible with the rank of parent (#{self.parent.rank_class.rank_name})")
      end
    end
  end

  def sv_missing_relationships
    if SPECIES_RANK_NAMES.include?(self.rank_class.to_s)
      soft_validations.add(:base, 'Original genus is not selected') if self.original_genus.nil?
    elsif GENUS_RANK_NAMES.include?(self.rank_class.to_s)
      soft_validations.add(:base, 'Type species is not selected') if self.type_species.nil?
    elsif FAMILY_RANK_NAMES.include?(self.rank_class.to_s)
      soft_validations.add(:base, 'Type genus is not selected') if self.type_genus.nil?
    end
    if !self.iczn_set_as_homonym_of.nil? || !TaxonNameClassification.where_taxon_name(self).with_type_string('TaxonNameClassification::Iczn::Available::Invalid::Homonym').empty?
      soft_validations.add(:base, 'The replacement name for the homonym is not selected') if self.iczn_set_as_synonym_of.nil?
    end
  end

  def sv_missing_classifications
    if SPECIES_RANK_NAMES.include?(self.rank_class.to_s)
      soft_validations.add(:base, 'Part of speech is not specified') if self.part_of_speech_class.nil?
    elsif GENUS_RANK_NAMES.include?(self.rank_class.to_s)
      if self.gender_class.nil?
        g = genus_suggested_gender
        soft_validations.add(:base, "Gender is not specified#{ g.nil? ? '' : ' (possible gender is ' + g + ')'}")
      end
    end
  end

  # Why protected
  def genus_suggested_gender
    return nil unless self.rank_class.to_s =~/Genus/
    TaxonNameClassification::Latinized::Gender.descendants.each do |g|
      g.possible_genus_endings.each do |e|
        return g.class_name if self.name =~ /^[a-zA-Z]*#{e}$/
      end
    end
    nil
  end

  def sv_species_gender_agreement
    if SPECIES_RANK_NAMES.include?(self.rank_class.to_s)
      s = self.part_of_speech_name
      unless self.part_of_speech_name.nil?
        if s =~ /(adjective|participle)/
          if self.feminine_name.blank?
            soft_validations.add(:feminine_name, 'Spelling in feminine is not provided')
          else
            e = species_questionable_ending(TaxonNameClassification::Latinized::Gender::Feminine, self.feminine_name)
            unless e.nil?
              soft_validations.add(:feminine_name, "Name has non feminine ending: -#{e}")
            end
          end
          if self.masculine_name.blank?
            soft_validations.add(:masculine_name, 'Spelling in masculine is not provided')
          else
            e = species_questionable_ending(TaxonNameClassification::Latinized::Gender::Masculine, self.masculine_name)
            unless e.nil?
              soft_validations.add(:masculine_name, "Name has non masculine ending: -#{e}")
            end
          end
          if self.neuter_name.blank?
            soft_validations.add(:neuter_name, 'Spelling in neuter is not provided')
          else
            e = species_questionable_ending(TaxonNameClassification::Latinized::Gender::Neuter, self.neuter_name)
            unless e.nil?
              soft_validations.add(:neuter_name, "Name has non neuter ending: -#{e}")
            end
          end
          if self.masculine_name.blank? && self.feminine_name.blank? && self.neuter_name.blank?
            g = self.ancestor_at_rank('genus').gender_class
            unless g.nil?
              e = species_questionable_ending(g, self.name)
              unless e.nil?
                soft_validations.add(:name, "Name has non #{g.class_name} ending: -#{e}")
              end
            end
          end
        else
          unless self.feminine_name.blank?
            soft_validations.add(:feminine_name, 'Alternative spelling is not required for the name being noun')
          end
          unless self.masculine_name.blank?
            soft_validations.add(:masculine_name, 'Alternative spelling is not required for the name being noun')
          end
          unless self.neuter_name.blank?
            soft_validations.add(:neuter_name, 'Alternative spelling is not required for the name being noun')
          end

        end
      end
    end
  end

  # why protected
  def species_questionable_ending(g, n)
    return nil unless self.rank_class.to_s =~/Species/
    g.questionable_species_endings.each do |e|
      return e if n =~ /^[a-z]*#{e}$/
    end
    nil
  end

  def sv_validate_coordinated_names
    list_of_coordinated_names.each do |t|
      soft_validations.add(:source_id, "The source does not match with the source of the coordinated #{t.rank_class.rank_name}",
                           fix: :sv_fix_coordinated_names, success_message: 'Source was updated') unless self.source_id == t.source_id
      soft_validations.add(:verbatim_author, "The author does not match with the author of the coordinated #{t.rank_class.rank_name}",
                           fix: :sv_fix_coordinated_names, success_message: 'Author was updated') unless self.verbatim_author == t.verbatim_author
      soft_validations.add(:year_of_publication, "The year does not match with the year of the coordinated #{t.rank_class.rank_name}",
                           fix: :sv_fix_coordinated_names, success_message: 'Year was updated') unless self.year_of_publication == t.year_of_publication
      soft_validations.add(:base, "The gender does not match with the gender of the coordinated #{t.rank_class.rank_name}",
                           fix: :sv_fix_coordinated_names, success_message: 'Gender was updated') if self.rank_class.to_s =~ /Genus/ && self.gender_class != t.gender_class
      soft_validations.add(:base, "The part of speech does not match with the part of speech of the coordinated #{t.rank_class.rank_name}",
                           fix: :sv_fix_coordinated_names, success_message: 'Gender was updated') if self.rank_class.to_s =~ /Species/ && self.part_of_speech_class != t.part_of_speech_class
      soft_validations.add(:base, "The original genus does not match with the original genus of coordinated #{t.rank_class.rank_name}",
                           fix: :sv_fix_coordinated_names, success_message: 'Original genus was updated') unless self.original_genus == t.original_genus
      soft_validations.add(:base, "The original subgenus does not match with the original subgenus of the coordinated #{t.rank_class.rank_name}",
                           fix: :sv_fix_coordinated_names, success_message: 'Original subgenus was updated') unless self.original_subgenus == t.original_subgenus
      soft_validations.add(:base, "The original species does not match with the original species of the coordinated #{t.rank_class.rank_name}",
                           fix: :sv_fix_coordinated_names, success_message: 'Original species was updated') unless self.original_species == t.original_species
      soft_validations.add(:base, "The type species does not match with the type species of the coordinated #{t.rank_class.rank_name}",
                           fix: :sv_fix_coordinated_names, success_message: 'Type species was updated') unless self.type_species == t.type_species
      soft_validations.add(:base, "The type genus does not match with the type genus of the coordinated #{t.rank_class.rank_name}",
                           fix: :sv_fix_coordinated_names, success_message: 'Type genus was updated') unless self.type_genus == t.type_genus
      soft_validations.add(:base, "The type specimen does not match with the type specimen of the coordinated #{t.rank_class.rank_name}",
                           fix: :sv_fix_coordinated_names, success_message: 'Type specimen was updated') unless self.has_same_primary_type(t)
      sttnr = self.type_taxon_name_relationship
      tttnr = t.type_taxon_name_relationship
      unless sttnr.nil? || tttnr.nil?
        soft_validations.add(:base, "The type species relationship does not match with the relationship of the coordinated #{t.rank_class.rank_name}",
                             fix: :sv_fix_coordinated_names, success_message: 'Type genus was updated') unless sttnr.type == tttnr.type
      end
    end

  end

  def sv_fix_coordinated_names
    fixed = false
    gender = self.gender_class
    speech = self.part_of_speech_class
    list_of_coordinated_names.each do |t|
      if self.source_id.nil? && self.source_id != t.source_id
        self.source_id = t.source_id
        fixed = true
      end
      if self.verbatim_author.nil? && self.verbatim_author != t.verbatim_author
        self.verbatim_author = t.verbatim_author
        fixed = true
      end
      if self.year_of_publication.nil? && !t.year_of_publication.nil?
        self.year_of_publication = t.year_of_publication
        fixed = true
      end
      t_gender = t.gender_class
      if gender.nil? && gender != t_gender
        self.TaxonNameClassification.build(type: t_gender.to_s)
        fixed = true
      end
      t_speech = t.part_of_speech_class
      if speech.nil? && speech != t_speech
        self.TaxonNameClassification.build(type: t_speech.to_s)
        fixed = true
      end
      if self.gender_class.nil? && !t.gender_class.nil?
        self.taxon_name_classification.build(type: t.gender_name)
        fixed = true
      end
      if self.original_genus.nil? && !t.original_genus.nil?
        self.original_combination_genus = t.original_combination_genus
        fixed = true
      end
      if self.original_subgenus.nil? && !t.original_subgenus.nil?
        self.original_combination_subgenus = t.original_combination_subgenus
        fixed = true
      end
      if self.original_species.nil? && !t.original_species.nil?
        self.original_combination_species = t.original_combination_species
        fixed = true
      end
      if self.type_species.nil? && !t.type_species.nil?
        self.type_species = t.type_species
        fixed = true
      end
      if self.type_genus.nil? && !t.type_genus.nil?
        self.type_genus = t.type_genus
        fixed = true
      end
      types1 = self.get_primary_type
      types2 = t.get_primary_type
      if types1.empty? && !types2.empty?
        new_type_material = []
        types2.each do |t|
          new_type_material.push({type_type: t.type_type, protonym_id: t.protonym_id, biological_object_id: t.biological_object_id, source_id: t.source_id})
        end
        self.type_materials.build(new_type_material)
        fixed = true
      end

      sttnr = self.type_taxon_name_relationship
      tttnr = t.type_taxon_name_relationship
      unless sttnr.nil? || tttnr.nil?
        if sttnr.type != tttnr.type && sttnr.type.safe_constantize.descendants.collect{|i| i.to_s}.include?(tttnr.type.to_s)
          self.type_taxon_name_relationship.type = t.type_taxon_name_relationship.type
          fixed = true
        end
      end
    end

    if fixed
      begin
        Protonym.transaction do
          self.save
        end
      rescue
        return false
      end
    end
    return fixed
  end

  def sv_type_placement
    # type of this taxon is not included in this taxon
    if !!self.type_taxon_name
      soft_validations.add(:base, "The type should be included in this #{self.rank_class.rank_name}") unless self.type_taxon_name.get_valid_taxon_name.ancestors.include?(self.get_valid_taxon_name)
    end
    # this taxon is a type, but not included in nominal taxon
    if !!self.type_of_taxon_names
      self.type_of_taxon_names.each do |t|
        soft_validations.add(:base, "This taxon is type of #{t.rank_class.rank_name} #{t.name} but is not included there") unless self.get_valid_taxon_name.ancestors.include?(t.get_valid_taxon_name)
      end
    end
  end

  def sv_primary_types
    if self.rank_class
      if self.rank_class.parent.to_s =~ /Species/
        if self.type_materials.primary.empty? && self.type_materials.syntypes.empty?
          soft_validations.add(:base, 'Primary type is not selected')
        elsif self.type_materials.primary.count > 1 || (!self.type_materials.primary.empty? && !self.type_materials.syntypes.empty?)
          soft_validations.add(:base, 'More than one primary type are selected')
        end
      end
    end
  end

  def sv_single_sub_taxon
    if self.rank_class
      rank = self.rank_class.to_s
      if rank != 'potentially_validating rank' && self.rank_class.nomenclatural_code == :iczn && %w(subspecies subgenus subtribe tribe subfamily).include?(self.rank_class.rank_name)
        sisters = self.parent.descendants.with_rank_class(rank)
        if rank =~ /Family/
          z = Protonym.family_group_base(self.name)
          search_name = z.nil? ? nil : Protonym::FAMILY_GROUP_ENDINGS.collect{|i| z+i}
          a = sisters.collect{|i| Protonym.family_group_base(i.name) }
          sister_names = a.collect{|z| Protonym::FAMILY_GROUP_ENDINGS.collect{|i| z+i} }.flatten
        else
          search_name = [self.name]
          sister_names = sisters.collect{|i| i.name }
        end
        if search_name.include?(self.parent.name) && sisters.count == 1
          soft_validations.add(:base, "This taxon is a single #{self.rank_class.rank_name} in the nominal #{self.parent.rank_class.rank_name}")
        elsif !sister_names.include?(self.parent.name)
          soft_validations.add(:base, "The parent #{self.parent.rank_class.rank_name} of this #{self.rank_class.rank_name} does not contain nominotypical #{self.rank_class.rank_name}",
                               fix: :sv_fix_add_nominotypical_sub, success_message: "Nominotypical #{self.rank_class.rank_name} was added to nominal #{self.parent.rank_class.rank_name}")
        end
      end
    end
  end

  def sv_fix_add_nominotypical_sub
    rank = self.rank_class.to_s
    p = self.parent
    begin
      Protonym.transaction do
        if rank =~ /Family/
          name = Protonym.family_group_base(self.parent.name)
          case self.rank_class.rank_name
          when 'subfamily'
            name += 'inae'
          when 'tribe'
            name += 'ini'
          when 'subtribe'
            name += 'ina'
          end
        else
          name = [p.name]
        end

        t = Protonym.new(name: name, rank_class: rank, verbatim_author: p.verbatim_author, year_of_publication: p.year_of_publication, source_id: p.source_id, parent: p)
        t.save
        t.soft_validate
        t.fix_soft_validations
        return true
      end
    rescue
    end
    false
  end

  def sv_parent_priority
    if self.rank_class
      rank_group = self.rank_class.parent
      parent = self.parent

      if parent && rank_group == parent.rank_class.parent
        unless self.unavailable_or_invalid?
          date1 = self.nomenclature_date
          date2 = parent.nomenclature_date
          unless date1.nil? || date2.nil?
            if date1 < date2
              soft_validations.add(:base, "#{self.rank_class.rank_name.capitalize} should not be older than parent #{parent.rank_class.rank_name}")
            end
          end
        end
      end
    end
  end

  def sv_homotypic_synonyms
    unless self.unavailable_or_invalid?
      if self.id == self.lowest_rank_coordinated_taxon.id
        possible_synonyms = []
        if self.rank_class.to_s =~ /Species/
          primary_types = self.get_primary_type
          unless primary_types.empty?
            p = primary_types.collect!{|t| t.biological_object_id}
            possible_synonyms = Protonym.with_type_material_array(p).that_is_valid.without_taxon_name_classification_array(TAXON_NAME_CLASS_NAMES_UNAVAILABLE_AND_INVALID).not_self(self).with_project(self.project_id)
          end
        else
          type = self.type_taxon_name
          unless type.nil?
            possible_synonyms = Protonym.with_type_of_taxon_names(type.id).that_is_valid.not_self(self).with_project(self.project_id)
          end
        end
        reduce_list_of_synonyms(possible_synonyms)
        possible_synonyms.each do |s|
          soft_validations.add(:base, "Taxon should be a synonym of #{s.cached_html + ' ' + s.cached_author_year} since they share the same type")
        end
      end
    end
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

  def sv_potential_homonyms
    if self.parent
      unless self.unavailable? || !Protonym.with_taxon_name_relationships_as_subject.with_homonym_or_suppressed.empty? #  self.unavailable_or_invalid?
        if self.id == self.lowest_rank_coordinated_taxon.id
          rank_base = self.rank_class.parent.to_s
          name1 = self.cached_primary_homonym ? self.cached_primary_homonym : nil
          possible_primary_homonyms = name1 ? Protonym.with_primary_homonym(name1).without_taxon_name_classification_array(TAXON_NAME_CLASS_NAMES_UNAVAILABLE_AND_INVALID).without_homonym_or_suppressed.not_self(self).with_base_of_rank_class(rank_base).with_project(self.project_id) : []
          list1 = reduce_list_of_synonyms(possible_primary_homonyms)
          if !list1.empty?
            list1.each do |s|
              if rank_base =~ /Species/
                soft_validations.add(:base, "Taxon should be a primary homonym of #{s.cached_name_and_author_year}")
                #  fix: :sv_fix_add_relationship('iczn_set_as_primary_homonym_of'.to_sym, s.id),
                #  success_message: 'Primary homonym relationship was added',
                #  failure_message: 'Fail to add a relationship')
              elsif
                soft_validations.add(:base, "Taxon should be an homonym of #{s.cached_name_and_author_year}")
              end
            end
          else
            name2 = self.cached_primary_homonym_alternative_spelling ? self.cached_primary_homonym_alternative_spelling : nil
            possible_primary_homonyms_alternative_spelling = name2 ? Protonym.with_primary_homonym_alternative_spelling(name2).without_homonym_or_suppressed.without_taxon_name_classification_array(TAXON_NAME_CLASS_NAMES_UNAVAILABLE_AND_INVALID).not_self(self).with_base_of_rank_class(rank_base).with_project(self.project_id) : []
            list2 = reduce_list_of_synonyms(possible_primary_homonyms_alternative_spelling)
            if !list2.empty?
              list2.each do |s|
                if rank_base =~ /Species/
                  soft_validations.add(:base, "Taxon could be a primary homonym of #{s.cached_name_and_author_year} (alternative spelling)")
                elsif
                  soft_validations.add(:base, "Taxon could be an homonym of #{s.cached_name_and_author_year} (alternative spelling)")
                end
              end
            elsif rank_base =~ /Species/
              name3 = self.cached_secondary_homonym ? self.cached_secondary_homonym : nil
              possible_secondary_homonyms = name3 ? Protonym.with_secondary_homonym(name3).without_homonym_or_suppressed.without_taxon_name_classification_array(TAXON_NAME_CLASS_NAMES_UNAVAILABLE_AND_INVALID).not_self(self).with_base_of_rank_class(rank_base).with_project(self.project_id) : []
              list3 = reduce_list_of_synonyms(possible_secondary_homonyms)
              if !list3.empty?
                list3.each do |s|
                  soft_validations.add(:base, "Taxon should be a secondary homonym of #{s.cached_name_and_author_year}")
                end
              else
                name4 = self.cached_secondary_homonym ? self.cached_secondary_homonym_alternative_spelling : nil
                possible_secondary_homonyms_alternative_spelling = name4 ? Protonym.with_secondary_homonym_alternative_spelling(name4).without_homonym_or_suppressed.without_taxon_name_classification_array(TAXON_NAME_CLASS_NAMES_UNAVAILABLE_AND_INVALID).not_self(self).with_base_of_rank_class(rank_base).with_project(self.project_id) : []
                list4 = reduce_list_of_synonyms(possible_secondary_homonyms_alternative_spelling)
                if !list4.empty?
                  list4.each do |s|
                    soft_validations.add(:base, "Taxon could be a secondary homonym of #{s.cached_name_and_author_year} (alternative spelling)")
                  end
                end
              end
            end
          end
        end
      end
    end
  end

  def sv_original_combination_relationships

    relationships = self.original_combination_relationships

    unless relationships.empty?
      relationships = relationships.sort_by{|r| r.type_class.order_index }
      ids = relationships.collect{|r| r.subject_taxon_name_id}

      if !ids.include?(self.id)
        soft_validations.add(:base, 'Original relationship to self is not specified')
      elsif ids.last != self.id
        soft_validations.add(:base, 'Original relationship to self should be selected at lowest nomeclatural rank of the original relationships')
      end
    end
  end

  def set_cached_names
    super 
    if self.errors.empty?

      set_cached_higher_classification
      set_primary_homonym
      set_primary_homonym_alternative_spelling

      if self.rank_class.to_s =~ /Species/
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

  def set_cached_higher_classification
    self.cached_higher_classification = get_higher_classification
  end

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

  #  def sv_fix_add_relationship(method, object_id)
  #    begin
  #      Protonym.transaction do
  #        self.save
  #        return true
  #      end
  #    rescue
  #      return false
  #    end
  #  false
  #  end

  #endregion

end

