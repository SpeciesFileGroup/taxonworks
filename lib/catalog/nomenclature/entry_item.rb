class Catalog::Nomenclature::EntryItem < ::Catalog::EntryItem
  
  def initialize(object: nil, base_object: nil, citation: nil, nomenclature_date: nil, citation_date: nil) 
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

  # @return [Boolean]
  def is_valid_name?
    object_class == 'Protonym' && object.is_valid?
  end

  def data_attributes
    base_data_attributes.merge(
      'history-valid-protonym' => is_valid_name? 
    )
  end

end
