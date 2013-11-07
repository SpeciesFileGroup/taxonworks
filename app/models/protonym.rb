class Protonym < TaxonName 

  has_many :taxon_name_classifications

  alias_method :original_combination_source, :source

  # subject                      object
  # Aus      original_genus of   bus
  # aus      type_species of     Bus

  soft_validate(:sv_missing_fields )
  soft_validate(:sv_missing_relationships)

  TaxonNameRelationship.descendants.each do |d|
    if d.respond_to?(:assignment_method) 
      relationship = "#{d.assignment_method}_relationship".to_sym
      has_one relationship, class_name: d.name.to_s, foreign_key: :object_taxon_name_id 
      has_one d.assignment_method.to_sym, through: relationship, source: :subject
    end

    if d.respond_to?(:inverse_assignment_method)
      # eval inverse method here
    end
  end

  has_one :type_taxon_name_relationship, -> {
    where("taxon_name_relationships.type LIKE 'TaxonNameRelationship::Typification::%'")
  }, class_name: 'TaxonNameRelationship', foreign_key: :object_taxon_name_id 
   
  has_one :type_taxon_name, through: :type_taxon_name_relationship, source: :subject

  has_many :type_of_relationships, -> {
    where("taxon_name_relationships.type LIKE 'TaxonNameRelationship::Typification::%'")
  }, class_name: 'TaxonNameRelationship', foreign_key: :subject_taxon_name_id

  has_many :type_of_taxon_names, through: :type_of_relationships, source: :object

  has_many :original_combination_relationships, -> {
    where("taxon_name_relationships.type LIKE 'TaxonNameRelationship::OriginalCombination::%'")
  }, class_name: 'TaxonNameRelationship', foreign_key: :subject_taxon_name_id


  #region Soft validation

  def sv_missing_fields
    soft_validations.add(:source_id, 'Source is missing') if self.source_id.nil?
    soft_validations.add(:verbatim_author, 'Author is missing') if self.verbatim_author.blank?
    soft_validations.add(:year_of_publication, 'Year is missing') if self.year_of_publication.nil?
  end

  def sv_missing_relationships
    if SPECIES_RANKS_NAMES.include?(self.rank_class.to_s)
      soft_validations.add(:base, 'Original genus is missing') if self.original_combination_genus.nil?
    end
  end

  #endregion

end
