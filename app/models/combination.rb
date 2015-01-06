class Combination < TaxonName

  # before_save :set_cached_original_combination

  has_many :combination_relationships, -> {
    joins(:taxon_name_relationships)
    where("taxon_name_relationships.type LIKE 'TaxonNameRelationship::Combination::%'")},
    class_name: 'TaxonNameRelationship', foreign_key: :object_taxon_name_id

  %w{genus subgenus section subsection series subseries species subspecies variety subvariety form subform}.each do |rank|
    has_one "#{rank}_taxon_name_relationship".to_sym, -> {
      joins(:combination_relationships)
      where(taxon_name_relationships: {type: "TaxonNameRelationship::Combination::#{rank.capitalize}"} )},
    class_name: 'TaxonNameRelationship', foreign_key: :object_taxon_name_id

    has_one rank.to_sym, -> {
      joins( :combination_relationships)
      where(taxon_name_relationships: {type: "TaxonNameRelationship::Combination::#{rank.capitalize}"} )
    }, through: "#{rank}_taxon_name_relationship".to_sym, source: :subject_taxon_name
  end
  has_one :source_classified_as_relationship, -> {
    where("taxon_name_relationships.type LIKE 'TaxonNameRelationship::SourceClassifiedAs'")
  }, class_name: 'TaxonNameRelationship', foreign_key: :object_taxon_name_id

  has_one :source_classified_as_taxon_name, through: :source_classified_as_relationship, source: :subject_taxon_name

  TaxonNameRelationship.descendants.each do |d|
    if d.name.to_s =~ /TaxonNameRelationship::(Combination|SourceClassifiedAs)/
      if d.respond_to?(:assignment_method)
        relationships = "#{d.assignment_method}_relationships".to_sym
        has_many relationships, -> {
          where("taxon_name_relationships.type LIKE '#{d.name.to_s}%'")
        }, class_name: 'TaxonNameRelationship', foreign_key: :subject_taxon_name_id
        has_many d.assignment_method.to_s.pluralize.to_sym, through: relationships, source: :object_taxon_name
      end
      if d.respond_to?(:inverse_assignment_method)
        relationship = "#{d.inverse_assignment_method}_relationship".to_sym
        has_one relationship, class_name: d.name.to_s, foreign_key: :object_taxon_name_id
        has_one d.inverse_assignment_method.to_sym, through: relationship, source: :subject_taxon_name
      end
    end
  end

  scope :with_parent_id, -> (parent_id) {where(parent_id: parent_id)}
  scope :with_cached_original_combination, -> (original_combination) {where(cached_original_combination: original_combination)}
  scope :not_self, -> (id) {where('taxon_names.id <> ?', id )}

  before_validation :validate_rank_class_class

  soft_validate(:sv_combination_duplicates, set: :combination_duplicates)

  #region Soft validation

  def sv_source_older_then_description
    date1 = self.nomenclature_date
    date2  = !!self.parent_id ? self.parent.nomenclature_date : nil
    if !!date1 && !!date2
      soft_validations.add(:year_of_publication, 'The combination is older than the taxon') if date2 - date1 > 0
    end
    if !!self.source && !!self.year_of_publication
      soft_validations.add(:source_id, 'The year of publication and the year of source do not match') if self.source.year != self.year_of_publication
    end
  end

  def sv_combination_duplicates
    duplicate = Combination.not_self(self.id).with_parent_id(self.parent_id).with_cached_original_combination(self.cached_original_combination)
    soft_validations.add(:base, 'Combination is a duplicate') unless duplicate.empty?
  end

  #endregion

  protected

  def set_cached_original_combination
    self.cached_original_combination = get_combination if self.errors.empty?
  end

  def set_cached_html
    self.cached_html = get_combination
  end

end
