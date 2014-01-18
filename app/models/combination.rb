class Combination < TaxonName

  include Housekeeping

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
    }, through: "#{rank}_taxon_name_relationship".to_sym, source: :object_taxon_name
  end


  before_validation :validate_rank_class_class


  #region Soft validation

  def sv_source_older_then_description
    if !!self.year_of_publication
      if !!self.source && !!self.year_of_publication
        soft_validations.add(:source_id, 'The year of publication and the year of reference do not match') if self.source.year != self.year_of_publication
      else
        parent_year = self.parent.year_of_publication
        if !!parent_year
          date1 = self.nomenclatural_date
          date2 = self.parent.nomenclatural_date
          if !!date1 && !!date2
            soft_validations.add(:source_id, 'The citation is older than the taxon') if date2 - date1 > 0
          else
            if !!self.source_id
              soft_validations.add(:source_id, 'The citation is older than the taxon') if self.source.year < parent_year
            end
            soft_validations.add(:year_of_publication, 'The combination is older than the taxon') if self.year_of_publication < self.parent.year_of_publication
          end
        end
      end
    end

  end

  #endregion

end
