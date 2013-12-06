class Protonym < TaxonName

  include Housekeeping

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

  soft_validate(:sv_source_older_then_description)
  soft_validate(:sv_validate_parent_rank)
  soft_validate(:sv_missing_relationships)
  soft_validate(:sv_type_species_placement)
  soft_validate(:sv_validate_coordinated_names)

  #TODO: validate if the rank can change, only within one group.

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
    if /NomenclaturalRank::Iczn::SpeciesGroup::+/.match(self.rank_class.to_s)
      search_name = self.name
      search_rank = 'NomenclaturalRank::Iczn::SpeciesGroup::'
    elsif /NomenclaturalRank::Iczn::GenusGroup::+/.match(self.rank_class.to_s)
      search_name = self.name
      search_rank = 'NomenclaturalRank::Iczn::GenusGroup::'
    elsif /NomenclaturalRank::Iczn::FamilyGroup::+/.match(self.rank_class.to_s)
      z = self.name.match(/(^.*)(ini|ina|inae|idae|oidae|odd|ad|oidea)/)
      if z.nil?
        search_name = nil
      else
        search_name = z[1] + '(ini|ina|inae|idae|oidae|odd|ad|oidea)'
      end
      search_rank = 'NomenclaturalRank::Iczn::FamilyGroup::'
    else
      search_name = nil
    end
    unless search_name.nil?
      list = self.ancestors.to_a + self.descendants.to_a
      list = list.select{|i| /#{search_rank}.*/.match(i.rank_class.to_s)}
      list = list.select{|i| /#{search_name}/.match(i.name)}
      list = list.reject{|i| i.unavailable_or_invalid?}
      list.each do |t|
        #:TODO think about fixes to tests below
        soft_validations.add(:source_id, "The source does not match with the source of the coordinated #{t.rank_class.rank_name}") if self.source_id != t.source_id
        soft_validations.add(:verbatim_author, "The author does not match with the author of the coordinated #{t.rank_class.rank_name}") if self.verbatim_author != t.verbatim_author
        soft_validations.add(:year_of_publication, "The year does not match with the year of the coordinated #{t.rank_class.rank_name}") if self.year_of_publication != t.year_of_publication
        soft_validations.add(:base, "The original genus does not match with the original genus of coordinated #{t.rank_class.rank_name}") if self.original_combination_genus != t.original_combination_genus
        soft_validations.add(:base, "The original subgenus does not match with the original subgenus of the coordinated #{t.rank_class.rank_name}") if self.original_combination_subgenus != t.original_combination_subgenus
        soft_validations.add(:base, "The original species does not match with the original species of the coordinated #{t.rank_class.rank_name}") if self.original_combination_species != t.original_combination_species
        soft_validations.add(:base, "The type species does not match with the type species of the coordinated #{t.rank_class.rank_name}") if self.type_species != t.type_species
        soft_validations.add(:base, "The type genus does not match with the type genus of the coordinated #{t.rank_class.rank_name}") if self.type_genus != t.type_genus
      end
    end
  end

  def sv_type_species_placement
    if !!self.type_species
      unless self.unavailable_or_invalid?
        soft_validations.add(:base, "The type species should be included in the #{self.rank_class.rank_name}") unless self.type_species.ancestors.include?(self)
      else
      end
    elsif !!self.type_genus && !self.unavailable_or_invalid?
      unless self.unavailable_or_invalid?
        soft_validations.add(:base, "The type genus should be included in the #{self.rank_class.rank_name}") unless self.type_genus.ancestors.include?(self)
      else
      end
    end
  end

  #endregion

end
