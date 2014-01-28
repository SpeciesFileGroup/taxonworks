class Protonym < TaxonName
  alias_method :original_combination_source, :source

  has_one :type_taxon_name_relationship, -> {
    where("taxon_name_relationships.type LIKE 'TaxonNameRelationship::Typification::%'")
  }, class_name: 'TaxonNameRelationship', foreign_key: :object_taxon_name_id
  has_one :type_taxon_name, through: :type_taxon_name_relationship, source: :subject_taxon_name
  has_many :type_of_relationships, -> {
    where("taxon_name_relationships.type LIKE 'TaxonNameRelationship::Typification::%'")
  }, class_name: 'TaxonNameRelationship', foreign_key: :subject_taxon_name_id
  has_many :type_of_taxon_names, through: :type_of_relationships, source: :object_taxon_name
  has_many :original_combination_relationships, -> {
    where("taxon_name_relationships.type LIKE 'TaxonNameRelationship::OriginalCombination::%'")
  }, class_name: 'TaxonNameRelationship', foreign_key: :object_taxon_name_id

  has_many :type_material

  # subject                      object
  # Aus      original_genus of   bus
  # aus      type_species of     Bus

  TaxonNameRelationship.descendants.each do |d|
    if d.respond_to?(:assignment_method)
      if d.name.to_s =~ /TaxonNameRelationship::(Iczn|Icn)/
        relationship = "#{d.assignment_method}_relationship".to_sym
        has_one relationship, class_name: d.name.to_s, foreign_key: :subject_taxon_name_id
        has_one d.assignment_method.to_sym, through: relationship, source: :object_taxon_name
      else
        relationships = "#{d.assignment_method}_relationships".to_sym
        has_many relationships, -> {
          where("taxon_name_relationships.type LIKE '#{d.name.to_s}%'")
        }, class_name: 'TaxonNameRelationship', foreign_key: :subject_taxon_name_id
        has_many d.assignment_method.to_sym, through: relationships, source: :object_taxon_name
      end
    end

    if d.respond_to?(:inverse_assignment_method)
      if d.name.to_s =~ /TaxonNameRelationship::(Iczn|Icn)/
        relationships = "#{d.inverse_assignment_method}_relationships".to_sym
        has_many relationships, -> {
          where("taxon_name_relationships.type LIKE '#{d.name.to_s}%'")
        }, class_name: 'TaxonNameRelationship', foreign_key: :object_taxon_name_id
        has_many d.inverse_assignment_method.to_sym, through: relationships, source: :subject_taxon_name
      else
        relationship = "#{d.inverse_assignment_method}_relationship".to_sym
        has_one relationship, class_name: d.name.to_s, foreign_key: :object_taxon_name_id
        has_one d.inverse_assignment_method.to_sym, through: relationship, source: :subject_taxon_name
      end
    end
  end

  scope :named, -> (name) {where(name: name)}
  scope :with_name_in_array, -> (array) { where('name in (?)', array) }  

  #  find classifications for taxon
  scope :with_taxon_name_classifications_on_taxon_name, -> (t) { includes(:taxon_name_classifications).where('taxon_name_classifications.taxon_name_id = ?', t).references(:taxon_name_classifications) }

  # find taxa with classifications
  scope :with_taxon_name_classifications, -> { joins(:taxon_name_classifications) }
  scope :with_taxon_name_classification, -> (taxon_name_class_name) { includes(:taxon_name_classifications).where('taxon_name_classifications.type = ?', taxon_name_class_name).references(:taxon_name_classifications) }
  scope :with_taxon_name_classification_base, -> (taxon_name_class_name_base) { includes(:taxon_name_classifications).where('taxon_name_classifications.type LIKE ?', "#{taxon_name_class_name_base}%").references(:taxon_name_classifications) }
  scope :with_taxon_name_classification_containing, -> (taxon_name_class_name_fragment) { includes(:taxon_name_classifications).where('taxon_name_classifications.type LIKE ?', "%#{taxon_name_class_name_fragment}%").references(:taxon_name_classifications) }
  scope :with_taxon_name_classification_array, -> (taxon_name_class_name_base_array) { includes(:taxon_name_classifications).where('taxon_name_classifications.type in (?)', taxon_name_class_name_base_array).references(:taxon_name_classifications) }
  scope :without_taxon_name_classification, -> (taxon_name_class_name) { where('id not in (SELECT taxon_name_id FROM taxon_name_classifications WHERE type LIKE ?)', "#{taxon_name_class_name}")}
  scope :without_taxon_name_classification_array, -> (taxon_name_class_name_array) { where('id not in (SELECT taxon_name_id FROM taxon_name_classifications WHERE type in (?))', taxon_name_class_name_array) }
  scope :without_taxon_name_classifications, -> { includes(:taxon_name_classifications).where(taxon_name_classifications: {taxon_name_id: nil}) }

  scope :that_is_valid, -> {
    joins('LEFT OUTER JOIN taxon_name_relationships tnr ON taxon_names.id = tnr.subject_taxon_name_id').
    where('taxon_names.id NOT IN (SELECT subject_taxon_name_id FROM taxon_name_relationships WHERE type LIKE "TaxonNameRelationship::Iczn::Invalidating%" OR type LIKE "TaxonNameRelationship::Icn::Unaccepting%")')
  }

  soft_validate(:sv_validate_parent_rank, set: :validate_parent_rank)
  soft_validate(:sv_missing_relationships, set: :missing_relationships)
  soft_validate(:sv_type_placement, set: :type_placement)
  soft_validate(:sv_validate_coordinated_names, set: :validate_coordinated_names)
  soft_validate(:sv_single_sub_taxon, set: :single_sub_taxon)
  soft_validate(:sv_parent_priority, set: :parent_priority)

  before_validation :check_format_of_name,
                    :validate_rank_class_class,
                    :validate_parent_rank_is_higher,
                    :check_new_rank_class,
                    :check_new_parent_class,
                    :validate_source_type,
                    :new_parent_taxon_name



  def list_of_coordinated_names
    if self.incorrect_original_spelling.nil?
      search_rank = NomenclaturalRank::Iczn.group_base(self.rank_string)
      if !!search_rank
        if search_rank =~ /Family/
          z = Protonym.family_group_base(self.name)
          search_name = z.nil? ? nil : NomenclaturalRank::Iczn::FamilyGroup::ENDINGS.collect{|i| z+i}
          #search_name = z.nil? ? nil : "#{z}(ini|ina|inae|idae|oidae|odd|ad|oidea)"
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
      list = [self.incorrect_original_spelling.object_taxon_name]
    end
    return list
  end

  def ancestors_and_descendants
    Protonym.ancestors_and_descendants_of(self).to_a
  end

  def self.family_group_base(name_string)
    name_string.match(/(^.*)(ini|ina|inae|idae|oidae|odd|ad|oidea)/)
    $1
  end

  protected

  def incorrect_original_spelling
    self.iczn_set_as_incorrect_original_spelling_of_relationship
    #TaxonNameRelationship.with_type_contains('IncorrectOriginalSpelling').where_subject_is_taxon_name(self).first
  end

  def incertae_sedis
    self.iczn_uncertain_placement_relationship
    #TaxonNameRelationship.with_type_contains('UncertainPlacement').where_subject_is_taxon_name(self).first
  end

  #region Validation

  def new_parent_taxon_name
    if !!self.incertae_sedis
      if self.parent != self.incertae_sedis.object_taxon_name
        errors.add(:parent_id, "Taxon has a relationship 'incertae sedis' - delete the relationship before changing the parent")
      end
    end
  end

  #endregion

  #region Soft validation

  def sv_source_older_then_description
    if self.source && self.year_of_publication
      soft_validations.add(:source_id, 'The year of publication and the year of reference do not match') if self.source.year != self.year_of_publication
    end
  end

  def sv_validate_parent_rank
    if self.rank_class.to_s == 'NomenclaturalRank' || self.parent.rank_class.to_s == 'NomenclaturalRank' || !!self.incertae_sedis
      true
    elsif !self.rank_class.valid_parents.include?(self.parent.rank_class.to_s)
      soft_validations.add(:rank_class, "The rank #{self.rank_class.rank_name} is not compatible with the rank of parent (#{self.parent.rank_class.rank_name})")
    end
  end

  def sv_missing_relationships
    if SPECIES_RANK_NAMES.include?(self.rank_class.to_s)
      soft_validations.add(:base, 'Original genus is missing') if self.original_combination_genus.nil?
    elsif GENUS_RANK_NAMES.include?(self.rank_class.to_s)
      soft_validations.add(:base, 'Type species is not selected') if self.type_species.nil?
    elsif FAMILY_RANK_NAMES.include?(self.rank_class.to_s)
      soft_validations.add(:base, 'Type genus is not selected') if self.type_genus.nil?
    end
  end

  def sv_validate_coordinated_names
      list_of_coordinated_names.each do |t|
        soft_validations.add(:source_id, "The source does not match with the source of the coordinated #{t.rank_class.rank_name}",
                             fix: :sv_fix_coordinated_names, success_message: 'Source was updated') unless self.source_id == t.source_id
        soft_validations.add(:verbatim_author, "The author does not match with the author of the coordinated #{t.rank_class.rank_name}",
                            fix: :sv_fix_coordinated_names, success_message: 'Author was updated') unless self.verbatim_author == t.verbatim_author
        soft_validations.add(:year_of_publication, "The year does not match with the year of the coordinated #{t.rank_class.rank_name}",
                            fix: :sv_fix_coordinated_names, success_message: 'Year was updated') unless self.year_of_publication == t.year_of_publication
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
    list_of_coordinated_names.each do |t|
      if self.source_id.nil? && self.source_id != t.source_id
        self.source_id = t.source_id
        fixed = true
      end
      if self.verbatim_author.nil? && self.verbatim_author != t.verbatim_author
        self.verbatim_author = t.verbatim_author
        fixed = true
      end
      if self.year_of_publication.nil? && self.year_of_publication != t.year_of_publication
        self.year_of_publication = t.year_of_publication
        fixed = true
      end
      if self.original_genus.nil? && self.original_genus != t.original_genus
        self.original_combination_genus = t.original_combination_genus
        fixed = true
      end
      if self.original_subgenus.nil? && self.original_subgenus != t.original_subgenus
        self.original_combination_subgenus = t.original_combination_subgenus
        fixed = true
      end
      if self.original_species.nil? && self.original_species != t.original_species
        self.original_combination_species = t.original_combination_species
        fixed = true
      end
      if self.type_species.nil? && self.type_species != t.type_species
        self.type_species = t.type_species
        fixed = true
      end
      if self.type_genus.nil? && self.type_genus != t.type_genus
        self.type_genus = t.type_genus
        fixed = true
      end

      sttnr = self.type_taxon_name_relationship
      tttnr = t.type_taxon_name_relationship
      unless sttnr.nil? || tttnr.nil?
        if sttnr.type != tttnr.type && sttnr.type.constantize.descendants.collect{|i| i.to_s}.include?(tttnr.type.to_s)
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

  def sv_single_sub_taxon
    rank = self.rank_class.to_s
    if rank != 'potentially_validating rank' && self.rank_class.nomenclatural_code == :iczn && %w(subspecies subgenus subtribe tribe subfamily).include?(self.rank_class.rank_name)
      sisters = self.parent.descendants.with_rank_class(rank)
      if rank =~ /Family/
        z = Protonym.family_group_base(self.name)
        search_name = z.nil? ? nil : NomenclaturalRank::Iczn::FamilyGroup::ENDINGS.collect{|i| z+i}
        a = sisters.collect{|i| Protonym.family_group_base(i.name) }
        sister_names = a.collect{|z| NomenclaturalRank::Iczn::FamilyGroup::ENDINGS.collect{|i| z+i} }.flatten
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
      return false
    end
    return false
  end

  def sv_parent_priority
    rank_group = self.rank_class.parent
    parent = self.parent
    if rank_group == parent.rank_class.parent
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

  #endregion

end
