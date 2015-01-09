# A {Combination} has no name, it exists to group related Protonyms into an epithet.
#
# A nomenclator name, composed of existing {Protonym}s. Each record reflects the subsequent use of one or more protonyms.  
# Only the first use of a combination is stored here, subsequence uses of this combination are referenced in citations. 
#
# They are applicable to genus group names and finer epithets.
#
# ```ruby
#  @combination.genus # => A {Protonym}
#  @combination.genus_combination_relationship 
# ```
#
# @!attribute combination_verbatim_name 
#   @return [String]
#     if differing from the auto-combined version fo the protonym the full epithet is provided here 
#
class Combination < TaxonName

  APPLICABLE_RANKS = %w{genus subgenus section subsection series subseries species subspecies variety subvariety form subform}

  # before_save :set_cached_original_combination

  has_many :combination_relationships, -> {
    joins(:taxon_name_relationships)
    where("taxon_name_relationships.type LIKE 'TaxonNameRelationship::Combination::%'") },
           class_name: 'TaxonNameRelationship', foreign_key: :object_taxon_name_id

  has_many :combination_taxon_names, through: :combination_relationships, source: :subject_taxon_name

  # Create the has_one associations
  APPLICABLE_RANKS.each do |rank|
    has_one "#{rank}_taxon_name_relationship".to_sym, -> {
      joins(:combination_relationships)
      where(taxon_name_relationships: {type: "TaxonNameRelationship::Combination::#{rank.capitalize}"}) },
            class_name: 'TaxonNameRelationship', foreign_key: :object_taxon_name_id

    has_one rank.to_sym, -> {
      joins(:combination_relationships)
      where(taxon_name_relationships: {type: "TaxonNameRelationship::Combination::#{rank.capitalize}"})
    }, through: "#{rank}_taxon_name_relationship".to_sym, source: :subject_taxon_name

     accepts_nested_attributes_for rank.to_sym
  end

  scope :with_cached_original_combination, -> (original_combination) { where(cached_original_combination: original_combination) }

  before_validation :validate_rank_class_class
  before_save :set_parent

  soft_validate(:sv_combination_duplicates, set: :combination_duplicates)

  #region Soft validation

  # easily handled by enumerating years of indivudal protonyms
  def sv_source_older_then_description
    date1 = self.nomenclature_date
    date2 = !!self.parent_id ? self.parent.nomenclature_date : nil
    if !!date1 && !!date2
      soft_validations.add(:year_of_publication, 'The combination is older than the name') if date2 - date1 > 0
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

  # The parent_id of a Combination is the parent_id of the genus (or highest) name in the epithet, it is automatically set
  def set_parent
    names = combination_taxon_names.to_a
    self.parent = names.first.parent if names.count > 0
  end

end
