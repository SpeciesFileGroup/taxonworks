
# Is 1:1 with a Citation
class Catalog::Nomenclature::EntryItem < ::Catalog::EntryItem
  # @param [Hash] args
  def initialize(object: nil, base_object: nil, citation: nil, nomenclature_date: nil, citation_date: nil) 
    # raise if nomenclature_date.nil? && !%w{Protonym Combination TaxonNameRelationship}.include?(object.class.to_s)
    super
  end

  def html_helper
    :nomenclature_catalog_entry_item_tag
  end

  # @return [Regex::Match]
  def from_relationship?
    object_class =~ /^TaxonNameRelationship/
  end

  # @return [String]
  def other_name
    if from_relationship?
      ([object.subject_taxon_name, object.object_taxon_name] - [base_object]).first
    end
  end

  # @return [String]
  def origin
    case object_class
    when 'Protonym'
      'protonym'
    when 'Hybrid'
      'hybrid'
    when 'Combination'
      'combination'
    when /TaxonNameRelationship/
      'taxon_name_relationship'
    else
      'error'
    end
  end

  # @return [Boolean]
  def is_valid_name?
    object_class == 'Protonym' && object.is_valid?
  end

  # @return [Boolean]
  def is_subsequent?
    # object == taxon_name && !citation.try(:is_original?)
    object == base_object && !citation.nil? && !citation.is_original?
  end

  def data_attributes
    base_data_attributes.merge(
      'history-valid-name' => is_valid_name? && is_subsequent?,
      'history-is-subsequent' => is_subsequent?
    )
  end

end
