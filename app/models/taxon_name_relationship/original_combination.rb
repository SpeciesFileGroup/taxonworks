
# Discussion (MJY, DD, 1/9/15) - It may be that this is semantically identical to Combination, and that we can infer the difference, i.e. functionality
# might get simplified/merged in the future.
#
# Conclusion- remains fixed as is, Combination becomes citable, Protonym not.
#
class TaxonNameRelationship::OriginalCombination < TaxonNameRelationship

  validates_uniqueness_of :object_taxon_name_id, scope: :type

  after_destroy :set_cached_original_combination # sets both cached/html

  def self.nomenclatural_priority
    :reverse
  end

  # @return [Symbol]
  #   the rank this relationship applies to as a symbol
  def applicable_rank
    self.class.name.demodulize.underscore.humanize.downcase.gsub('original ', '').to_sym
  end

  # TODO: Why only ICN?
  def self.order_index
    RANKS.index(::ICN_LOOKUP[self.name.demodulize.underscore.humanize.downcase.gsub('original ', '')])
  end

  def object_status_connector_to_subject
    ' with'
  end

  # @return String
  #    the status inferred by the relationship to the subject name
  def subject_status
    'as ' +  self.type_name.demodulize.underscore.humanize.downcase
  end

  def subject_status_connector_to_object
    ' of'
  end

  # @return String
  #    the status inferred by the relationship to the object name
  def object_status
    'in original combination with ' +  self.type_name.demodulize.underscore.humanize.downcase
  end

  def object_status_connector_to_subject
    ''
  end

  # @return [String, nil]  
  #   String should be included in Protonym::
  def monominal_prefix
    nil
  end

  # @return [Hash]
  #   like { genus: [nil, 'Aus'] ... }
  #   the elements of the original combination name for this instance
  #   TODO: reconcile this with <>_name_elements for other combinations.
  #   TODO: reconcile this format with that of full_name_hash
  def combination_name(name_gender = nil)
    elements = [monominal_prefix]
    if !subject_taxon_name.verbatim_name.blank? && name_gender.nil?
      elements.push subject_taxon_name.verbatim_name
    else
      elements.push subject_taxon_name.genderized_name(name_gender)
    end

    elements.push('[sic]') if subject_taxon_name.cached_misspelling
    elements[1] = "(#{elements[1]})" if applicable_rank == :subgenus

    return {applicable_rank => elements}
  end

# def element_gender
#   object_taxon_name.original_genus.gender_name
#    subject_taxon_name.gender_name
# end

  protected

  def set_cached_original_combination
    self.object_taxon_name.update_cached_original_combinations
  end

  def sv_validate_priority
    date1 = self.subject_taxon_name.nomenclature_date
    date2 = self.object_taxon_name.nomenclature_date
    if !!date1 && !!date2 && date1 > date2 && subject_invalid_statuses.empty?
      soft_validations.add(:type, "#{self.subject_status.capitalize} #{self.subject_taxon_name.cached_html_name_and_author_year} should not be younger than #{self.object_taxon_name.cached_html_name_and_author_year}")
    end
  end

  def sv_coordinated_taxa_object
    true # not applicable
  end
end
