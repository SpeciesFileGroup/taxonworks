class Protonym < TaxonName

  has_many :taxon_name_classifications

  alias_method :original_combination_source, :source

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
      # eval inverse method here
    end
  end

  has_one :type_taxon_name_relationship, -> {
    where("taxon_name_relationships.type LIKE 'TaxonNameRelationship::Typification::%'")
  }, class_name: 'TaxonNameRelationship', foreign_key: :object_taxon_name_id 
  has_one :type_taxon_name, through: :type_taxon_name_relationship, source: :subject_taxon_name
  has_many :type_of_relationships, -> {
    where("taxon_name_relationships.type LIKE 'TaxonNameRelationship::Typification::%'")
  }, class_name: 'TaxonNameRelationship', foreign_key: :subject_taxon_name_id
  has_many :type_of_taxon_names, through: :type_of_relationships, source: :object_taxon_name
  has_many :original_combination_relationships, -> {
    where("taxon_Name_relationships.type LIKE 'TaxonNameRelationship::OriginalCombination::%'")
  }, class_name: 'TaxonNameRelationship', foreign_key: :object_taxon_name_id

  scope :named, -> (name) {where(name: name)}
  scope :with_name_in_array, -> (array) { where('name in (?)', array) }  

  scope :as_subject_with_taxon_name_relationship, -> (taxon_name_relationship) { includes(:taxon_name_relationships).where(taxon_name_relationships: {type: taxon_name_relationship}) }
  scope :as_subject_with_taxon_name_relationship_base, -> (taxon_name_relationship) { includes(:taxon_name_relationships).where('taxon_name_relationships.type LIKE ?', "#{taxon_name_relationship}%").references(:taxon_name_relationships) }
  scope :as_subject_with_taxon_name_relationship_containing, -> (taxon_name_relationship) { includes(:taxon_name_relationships).where('taxon_name_relationships.type LIKE ?', "%#{taxon_name_relationship}%").references(:taxon_name_relationships) }

  scope :as_object_with_taxon_name_relationship, -> (taxon_name_relationship) { includes(:related_taxon_name_relationships).where(taxon_name_relationships: {type: taxon_name_relationship}) }
  scope :as_object_with_taxon_name_relationship_base, -> (taxon_name_relationship) { includes(:related_taxon_name_relationships).where('taxon_name_relationships.type LIKE ?', "#{taxon_name_relationship}%").references(:related_taxon_name_relationships) }
  scope :as_object_with_taxon_name_relationship_containing, -> (taxon_name_relationship) { includes(:related_taxon_name_relationships).where('taxon_name_relationships.type LIKE ?', "%#{taxon_name_relationship}%").references(:related_taxon_name_relationships) }

  scope :with_taxon_name_relationship, -> (relationship) { 
    joins('LEFT OUTER JOIN taxon_name_relationships tnr1 ON taxon_names.id = tnr1.subject_taxon_name_id').
    joins('LEFT OUTER JOIN taxon_name_relationships tnr2 ON taxon_names.id = tnr2.object_taxon_name_id').
    where('tnr1.type = ? OR tnr2.type = ?', relationship, relationship) 
  }
  
  scope :with_taxon_name_relationships_as_subject, -> {joins(:taxon_name_relationships)}
  scope :with_taxon_name_relationships_as_object, -> {joins(:related_taxon_name_relationships)}
  scope :with_taxon_name_relationships, -> {
    joins('LEFT OUTER JOIN taxon_name_relationships tnr1 ON taxon_names.id = tnr1.subject_taxon_name_id').
    joins('LEFT OUTER JOIN taxon_name_relationships tnr2 ON taxon_names.id = tnr2.object_taxon_name_id').
    where('tnr1.subject_taxon_name_id IS NOT NULL OR tnr2.object_taxon_name_id IS NOT NULL') 
  }
  scope :without_subject_taxon_name_relationships, -> { includes(:taxon_name_relationships).where(taxon_name_relationships: {subject_taxon_name_id: nil}) }
  scope :without_object_taxon_name_relationships, -> { includes(:related_taxon_name_relationships).where(taxon_name_relationships: {object_taxon_name_id: nil}) }
  scope :without_taxon_name_relationships, -> { 
    joins('LEFT OUTER JOIN taxon_name_relationships tnr1 ON taxon_names.id = tnr1.subject_taxon_name_id').
    joins('LEFT OUTER JOIN taxon_name_relationships tnr2 ON taxon_names.id = tnr2.object_taxon_name_id').
    where('tnr1.subject_taxon_name_id IS NULL AND tnr2.object_taxon_name_id IS NULL') 
  }

  soft_validate(:sv_source_older_then_description)
  soft_validate(:sv_validate_parent_rank)
  soft_validate(:sv_missing_relationships)
  soft_validate(:sv_type_placement)
  soft_validate(:sv_validate_coordinated_names)

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
        on_subject_without_taxon_name_relationship_base('TaxonNameRelationship::Iczn::Invalidating::Synonym').to_a
      list1 = self.ancestors_and_descendants                               # scope with parens
      list1 = list1.select{|i| /#{search_rank}.*/.match(i.rank_class.to_s)} # scope on rank_class
      list1 = list1.select{|i| /#{search_name}/.match(i.name)}              # scope on named
      list1 = list1.reject{|i| i.unavailable_or_invalid?}                   # scope with join on taxon_name_relationships and where > 1 on them

      # Using scopes assignment will be done with single query rather than loops, and be something like:
      #  list = TaxonName.ancestors_and_descendants_of(self).with_rank_of(search_rank).named(<something?!>).unavailable.invalid

      list.each do |t|
        #:TODO think about fixes to tests below
        soft_validations.add(:source_id, "The source does not match with the source of the coordinated #{t.rank_class.rank_name}",
                             fix: :sv_fix_coordinated_names, success_message: 'Source was updated') if self.source_id != t.source_id
        soft_validations.add(:verbatim_author, "The author does not match with the author of the coordinated #{t.rank_class.rank_name}",
                            fix: :sv_fix_coordinated_names, success_message: 'Author was updated') if self.verbatim_author != t.verbatim_author
        soft_validations.add(:year_of_publication, "The year does not match with the year of the coordinated #{t.rank_class.rank_name}",
                            fix: :sv_fix_coordinated_names, success_message: 'Year was updated') if self.year_of_publication != t.year_of_publication
        soft_validations.add(:base, "The original genus does not match with the original genus of coordinated #{t.rank_class.rank_name}",
                            fix: :sv_fix_coordinated_names, success_message: 'Original genus was updated') if self.original_combination_genus != t.original_combination_genus
        soft_validations.add(:base, "The original subgenus does not match with the original subgenus of the coordinated #{t.rank_class.rank_name}",
                            fix: :sv_fix_coordinated_names, success_message: 'Original subgenus was updated') if self.original_combination_subgenus != t.original_combination_subgenus
        soft_validations.add(:base, "The original species does not match with the original species of the coordinated #{t.rank_class.rank_name}",
                            fix: :sv_fix_coordinated_names, success_message: 'Original species was updated') if self.original_combination_species != t.original_combination_species
        soft_validations.add(:base, "The type species does not match with the type species of the coordinated #{t.rank_class.rank_name}",
                            fix: :sv_fix_coordinated_names, success_message: 'Type species was updated') if self.type_species != t.type_species
        soft_validations.add(:base, "The type genus does not match with the type genus of the coordinated #{t.rank_class.rank_name}",
                            fix: :sv_fix_coordinated_names, success_message: 'Type genus was updated') if self.type_genus != t.type_genus
      end
    end
  end

  def sv_fix_coordinated_names
    #TODO: how to get
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

  #endregion

end
