
# Discussion (MJY, DD, 1/9/15) - It may be that this is semantically identical to Combination, and that we can infer the difference, i.e. functionality
# might get simplified/merged in the future.
#
# Conclusion- remains fixed as is, Combination becomes citable, Protonym not.
#
class TaxonNameRelationship::OriginalCombination < TaxonNameRelationship

  validates_uniqueness_of :object_taxon_name_id, scope: :type

  after_destroy :set_cached_original_combination

  def self.nomenclatural_priority
    :reverse
  end

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

  protected

  def set_cached_original_combination
    self.object_taxon_name.update_cached_original_combinations
  end

end
