# A {Combination} has no name, it exists to group related Protonyms into an epithet.
#
# A nomenclator name, composed of existing {Protonym}s. Each record reflects the subsequent use of two or more protonyms.  
# Only the first use of a combination is stored here, subsequence uses of this combination are referenced in citations. 
#
# They are applicable to genus group names and finer epithets.
#
# All elements of the combination must be defined, nothing is assumed based on the relationhip to the parent.
#
#  c = Combination.new
#  c.genus = a_protonym_genus  
#  c.species = a_protonym_species
#  c.save # => true
#  c.genus_taxon_name_relationship  # => A instance of TaxonNameRelationship::Combination::Genus
#
#  # or
#
#  c = Combination.new(genus: genus_protonym, species: species_protonym)
#
#
# @!attribute combination_verbatim_name 
#   Use with caution, and sparingly! If the combination of values from Protonyms can not reflect the formulation of the combination as provided by the original author that string can be provided here.
#   The verbatim value is not further parsed. It is only provided to clarify what the combination looked like when first published.
#   The following recommendations are made:
#     1) The provided string should visually reflect as close as possible what was seen in the publication itself, including 
#     capitalization, accented characters etc. 
#     2) The full epithet (combination) should be provided, not just the differing component part (see 3 below).
#     3) Misspellings can be more acurately reflected by creating new Protonyms.
#   Example uses:
#     1) Jones 1915 publishes Aus aus. Smith 1920 uses, literally "Aus (Bus) Janes 1915". 
#        It is clear "Janes" is "Jones", therefor "Aus (Bus) Janes 1915" is provided as combination_verbatim_name.
#     2) Smith 1800 publishes Aus Jonesi (i.e. Aus jonesi). The combination_combination_verbatim name is used to
#        provide the fact that Jonesi was capitalized.  
#     3) "Aus brocen" is used for "Aus broken".  If the curators decide not to create a new protonym, perhaps because
#        they feel "brocen" was a printing press error that left off the straight bit of the "k" then they should minimally
#        include "Aus brocen" in this field, rather than just "brocen". An alternative is to create a new Protonym "brocen".
#   @return [String]
#
#
# @!attribute parent_id 
#   the parent is the parent of the highest ranked component protonym, it is automatically set i.e. it should never be assigned directly 
#   @return [Integer]
#   
class Combination < TaxonName

  # The ranks that can be used to build combinations.
  APPLICABLE_RANKS = %w{genus subgenus section subsection series subseries species subspecies variety subvariety form subform}

  before_validation :set_parent

  has_many :combination_relationships, -> {
    joins(:taxon_name_relationships)
    where("taxon_name_relationships.type LIKE 'TaxonNameRelationship::Combination::%'") 
  }, class_name: 'TaxonNameRelationship', foreign_key: :object_taxon_name_id

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

  validate :at_least_two_protonyms_are_included,
    :parent_is_properly_set

  soft_validate(:sv_combination_duplicates, set: :combination_duplicates)
  soft_validate(:sv_year_of_publication_matches_source, set: :dates)
  soft_validate(:sv_year_of_publication_not_older_than_protonyms, set: :dates)
  soft_validate(:sv_source_not_older_than_protonyms, set: :dates)

  # @return [Array of TaxonName]
  #   pre-ordered by rank 
  def protonyms 
    if self.new_record?
      protonyms_by_association
    else
      self.combination_taxon_names.ordered_by_rank
    end
  end

  # Overrides {TaxonName#full_name_hash}  
  # @return [Hash]
  def full_name_hash
    gender = nil
    data   = {}
    protonyms_by_rank.each do |rank, name|
      gender = name.gender_name if rank == 'genus'
      method = "#{rank.gsub(/\s/, '_')}_name_elements"
      data.merge!(rank => send(method, name, gender)) if self.respond_to?(method)
    end
    data
  end

  # @return [Array of TaxonNames, nil]
  #   the component names for this combination prior (used to return values prior to save) to it being saved
  def protonyms_by_rank
    result = {}
    APPLICABLE_RANKS.each do |rank|
      if protonym = self.send(rank)
        result.merge!(rank => protonym)
      end
    end
    result
  end

  # @return [Array of Integer]
  #   the collective years the protonyms were (nomenclaturaly) published on (ordered from genus to below)
  def publication_years 
    description_years = protonyms.collect{|a| a.nomenclature_date.year}.compact
  end

  # @return [Integer, nil]
  #   the earliest year (nomenclature) that a component Protonym was published on 
  def earliest_protonym_year
    publication_years.sort.first
  end

  protected

  # @return [Array of TaxonNames, nil]
  #   return the component names for this combination prior to it being saved
  def protonyms_by_association
    APPLICABLE_RANKS.collect{|r| self.send(r)}.compact
  end

  # TODO: this is a TaxonName level validation, it doesn't belong here 
  def sv_year_of_publication_matches_source
    source_year = self.source.nomenclature_year if self.source
    if self.year_of_publication && source_year
      soft_validations.add(:year_of_publication, 'the asserted published date is not the same as provided by the source') if source_year != self.year_of_publication
    end
  end

  def sv_source_not_older_than_protonyms
    source_year = self.source.nomenclature_year if self.source
    target_year = earliest_protonym_year
    if source_year && target_year
      soft_validations.add(:source_id, 'the published date for the source is older than a name in the combination') if source_year < target_year
    end
  end

  def sv_year_of_publication_not_older_than_protonyms
    combination_year = self.year_of_publication
    target_year = earliest_protonym_year
    if combination_year && target_year
      soft_validations.add(:year_of_publication, 'the asserted published date is older than a name in the combination') if combination_year < target_year
    end
  end

  def sv_combination_duplicates
    duplicate = Combination.not_self(self.id).with_parent_id(self.parent_id).with_cached_original_combination(self.cached_original_combination)
    soft_validations.add(:base, 'Combination is a duplicate') unless duplicate.empty?
  end

  def set_parent
    names = self.protonyms 
    if names.count > 0
      self.parent = names.first.parent if names.first.parent
    end
  end

  def set_cached
    self.cached = get_full_name_no_html
  end

  def set_cached_html
    self.cached_html = get_full_name
  end

  # validations

  # The parent of a Combination is the parent of the highest ranked protonym in that combination 
  def parent_is_properly_set
    check = protonyms.first
    if self.parent && check && check.parent
      errors.add(:base, 'Parent is not highest ranked member') if  self.parent != check.parent  
    end
  end

  def at_least_two_protonyms_are_included
    errors.add(:base, 'Combination includes no protonyms, it is not valid') if protonyms.count < 2 
  end

end
