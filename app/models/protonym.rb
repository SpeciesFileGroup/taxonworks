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

  # subject                      object
  # Aus      original_genus of   bus
  # aus      type_species of     Bus
  
  TaxonNameRelationship.descendants.each do |d|
    if d.respond_to?(:assignment_method) 
      relationship = "#{d.assignment_method}_relationship".to_sym
      has_one relationship, class_name: d.name.to_s, foreign_key: :object_taxon_name_id 
      has_one d.assignment_method.to_sym, through: relationship, source: :subject_taxon_name
    end

    if d.respond_to?(:inverse_assignment_method)
      # TODO: eval inverse method here
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
    # joins('LEFT OUTER JOIN taxon_name_classifications tnc ON taxon_names.id = tnc.taxon_name_id').
    # where('( (tnr.type NOT LIKE "TaxonNameRelationship::Iczn::Invalidating%" AND tnr.type NOT LIKE "TaxonNameRelationship::Icn::Unaccepting%") OR tnr.type IS NULL )') # AND (( tnc.type NOT LIKE "" AND tnc.type NOT LIKE "") OR tnc.type is null)) OR (tnr.id IS NULL AND tnc.id IS NULL)
    where('taxon_names.id NOT IN (SELECT subject_taxon_name_id FROM taxon_name_relationships WHERE type LIKE "TaxonNameRelationship::Iczn::Invalidating%" OR type LIKE "TaxonNameRelationship::Icn::Unaccepting%")')
  }

  soft_validate(:sv_source_older_then_description, set: :promblematic_relationships)
  soft_validate(:sv_validate_parent_rank, set: :promblematic_relationships)
  soft_validate(:sv_missing_relationships, set: :missing_relationships)
  soft_validate(:sv_type_placement, set: :type)
  soft_validate(:sv_type_relationship, set: :type)
  soft_validate(:sv_validate_coordinated_names, set: :coordinated_names)
  soft_validate(:sv_single_sub_taxon, set: :coordinated_names)

  #region Soft validation


  def sv_source_older_then_description
    if self.source && self.year_of_publication
      soft_validations.add(:source_id, 'The year of publication and the year of reference do not match') if self.source.year != self.year_of_publication
    end
  end

  def sv_validate_parent_rank
    if self.rank_class.to_s == 'NomenclaturalRank'
      true
    elsif self.parent.rank_class.to_s == 'NomenclaturalRank'
      true
    elsif !self.rank_class.valid_parents.include?(self.parent.rank_class.to_s)
      soft_validations.add(:rank_class, "The rank #{self.rank_class.rank_name} is not compatible with the rank of parent (#{self.parent.rank_class.rank_name})")
    end
  end

  def sv_missing_relationships
    if SPECIES_RANKS_NAMES.include?(self.rank_class.to_s)
      soft_validations.add(:base, 'Original genus is missing') if self.original_combination_genus.nil?
    elsif GENUS_RANKS_NAMES.include?(self.rank_class.to_s)
      soft_validations.add(:base, 'Type species is not selected') if self.type_species.nil?
    elsif FAMILY_RANKS_NAMES.include?(self.rank_class.to_s)
      if self.type_genus.nil?
        soft_validations.add(:base, 'Type genus is not selected')
      elsif self.name.slice(0, 1) != self.type_genus.name.slice(0, 1)
        soft_validations.add(:base, 'Type genus should have the same initial letters as the family-group name')
      end
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
                            fix: :sv_fix_coordinated_names, success_message: 'Original genus was updated') unless self.original_combination_genus == t.original_combination_genus
        soft_validations.add(:base, "The original subgenus does not match with the original subgenus of the coordinated #{t.rank_class.rank_name}",
                            fix: :sv_fix_coordinated_names, success_message: 'Original subgenus was updated') unless self.original_combination_subgenus == t.original_combination_subgenus
        soft_validations.add(:base, "The original species does not match with the original species of the coordinated #{t.rank_class.rank_name}",
                            fix: :sv_fix_coordinated_names, success_message: 'Original species was updated') unless self.original_combination_species == t.original_combination_species
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
      if self.original_combination_genus.nil? && self.original_combination_genus != t.original_combination_genus
        self.original_combination_genus = t.original_combination_genus
        fixed = true
      end
      if self.original_combination_subgenus.nil? && self.original_combination_subgenus != t.original_combination_subgenus
        self.original_combination_subgenus = t.original_combination_subgenus
        fixed = true
      end
      if self.original_combination_species.nil? && self.original_combination_species != t.original_combination_species
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
    foo = 0
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

  def list_of_coordinated_names
    search_rank = NomenclaturalRank::Iczn.group_base(self.rank_string)
    if search_rank
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
    return list
  end

  def ancestors_and_descendants
    Protonym.ancestors_and_descendants_of(self).to_a
  end

  def self.family_group_base(name_string)
    name_string.match(/(^.*)(ini|ina|inae|idae|oidae|odd|ad|oidea)/)
    $1
  end

  def sv_type_placement
    # type of this taxon is not included in this taxon
    if !!self.type_taxon_name
      unless self.unavailable_or_invalid?
        soft_validations.add(:base, "The type should be included in this #{self.rank_class.rank_name}") unless self.type_taxon_name.ancestors.include?(self)
      else
        #TODO: extend to cover synonyms
      end
    end
    # this taxon is a type, but not included in nominal taxon
    if !!self.type_of_taxon_names
      unless self.unavailable_or_invalid?
        self.type_of_taxon_names.each do |t|
          soft_validations.add(:base, "This taxon is type of #{t.rank_class.rank_name} #{t.name} but is not included there") unless self.ancestors.include?(t)
        end
      else
        #TODO: extend to cover synonyms
      end
    end
  end

  def sv_type_relationship

    unless self.type_taxon_name_relationship.nil?
      case self.type_taxon_name_relationship.type.to_s
        when 'TaxonNameRelationship::Typification::Genus'
          soft_validations.add(:base, "Please specify if the type designation is original or subsequent")
        when 'TaxonNameRelationship::Typification::Genus::Monotypy'
          soft_validations.add(:base, "Please specify if the monotypy is original or subsequent")
        when 'TaxonNameRelationship::Typification::Genus::Tautonomy'
          soft_validations.add(:base, "Please specify if the tautonomy is absolute or Linnaean")
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
        foo = 0
        return true
      end
    rescue
      return false
    end
    return false
  end


  #endregion

end
