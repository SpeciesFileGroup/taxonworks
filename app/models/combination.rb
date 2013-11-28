class Combination < TaxonName

  has_many :combination_relationships, -> {
    joins(:taxon_name_relationships)
    where("taxon_name_relationships.type LIKE 'TaxonNameRelationship::Combination::%'")},
    class_name: 'TaxonNameRelationship', foreign_key: :subject_taxon_name_id

  %w{genus subgenus section subsection series subseries species subspecies variety subvariety form subform}.each do |rank|
    has_one "#{rank}_taxon_name_relationship".to_sym, -> {
      joins(:combination_relationships)
      where(taxon_name_relationships: {type: "TaxonNameRelationship::Combination::#{rank.capitalize}"} )},
    class_name: 'TaxonNameRelationship', foreign_key: :subject_taxon_name_id 

    has_one rank.to_sym, -> {
      joins( :combination_relationships)
      where(taxon_name_relationships: {type: "TaxonNameRelationship::Combination::#{rank.capitalize}"} )
    }, through: "#{rank}_taxon_name_relationship".to_sym, source: :object    
  end

  soft_validate(:sv_validate_parent_rank)

  #region Soft validation

  def sv_source_older_then_description
    if self.source && self.year_of_publication
      soft_validations.add(:source_id, 'The year of publication and the year of reference do not match') if self.source.year != self.year_of_publication
      if self.parent.year_of_publication
        soft_validations.add(:source_id, 'The citation is older than the taxon') if self.source.year < self.parent.year_of_publication
        soft_validations.add(:year_of_publication, 'The combination is older than the taxon') if self.year_of_publication < self.parent.year_of_publication
      end
    end
  end

  #endregion

end
