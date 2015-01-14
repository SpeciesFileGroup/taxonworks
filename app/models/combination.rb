# A {Combination} has no name, it exists to group related Protonyms into an epithet.
#
# A nomenclator name, composed of existing {Protonym}s. Each record reflects the subsequent use of one or more protonyms.  
# Only the first use of a combination is stored here, subsequence uses of this combination are referenced in citations. 
#
# They are applicable to genus group names and finer epithets.
#
# ```ruby
#  c = Combination.new
#  c.genus = a_protonym_genus  
#  c.save # => true
#  c.genus_taxon_name_relationship  # A TaxonNameRelationship::Combination::Genus
# ```
#
# @!attribute combination_verbatim_name 
#   @return [String]
#     if differing from the auto-combined version fo the protonym the full epithet is provided here 
#
# @!attribute parent_id
#   the parent is the parent of the highest ranked component protonym, it is automatically set, 
#   i.e. it should never be assigned directly 
#  @return [Integer]
#   
class Combination < TaxonName

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

  validate :at_least_one_protonym_is_included,
    :parent_is_properly_set

  soft_validate(:sv_combination_duplicates, set: :combination_duplicates)
  soft_validate(:sv_source_older_then_description, set: :source_older_then_description)

  # @return [Array of TaxonName]
  #   pre-ordered by rank 
  def protonyms 
    if self.new_record?
      protonyms_by_association
    else
      self.combination_taxon_names.ordered_by_rank
    end
  end

  # @return [Hash]
  #   overrides @taxon_name.full_name_hash
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
  #   return the component names for this combination prior to it being saved
  def protonyms_by_rank
    result = {}
    APPLICABLE_RANKS.each do |rank|
      if protonym = self.send(rank)
        result.merge!(rank => protonym)
      end
    end
    result
  end

  protected

  # @return [Array of TaxonNames, nil]
  #   return the component names for this combination prior to it being saved
  def protonyms_by_association
    APPLICABLE_RANKS.collect{|r| self.send(r)}.compact
  end

  # Easily handled by enumerating years of individual protonyms
  def sv_source_older_then_description
    date1 = self.nomenclature_date
    date2 = parent ? self.parent.nomenclature_date : nil
    if date1 && date2
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

  # The parent_id of a Combination is the parent_id of the genus (or highest) name in the epithet, it is automatically set
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

  # The parent of a combination is the parent of the highest ranked protonym in that combination 
  def parent_is_properly_set
    check = protonyms.first
    if self.parent && check && check.parent
      errors.add(:base, 'Parent is not highest ranked member') if  self.parent != check.parent  
    end
  end

  def at_least_one_protonym_is_included
    errors.add(:base, 'Combination includes no protonyms, it is not valid') if protonyms.empty? 
  end

end
