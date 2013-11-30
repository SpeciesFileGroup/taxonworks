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
    where("taxon_Name_relationships.type LIKE 'TaxonNameRelationship::OriginalCombination::%'")
  }, class_name: 'TaxonNameRelationship', foreign_key: :object_taxon_name_id

  soft_validate(:sv_source_older_then_description)

  #TODO: validate if the rank can change, only within one group.

  #region Soft validation

  def sv_source_older_then_description
    if self.source && self.year_of_publication
      soft_validations.add(:source_id, 'The year of publication and the year of reference do not match') if self.source.year != self.year_of_publication
    end
  end

  #endregion

end
