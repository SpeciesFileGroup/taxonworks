
require 'catalog/entry_item'
class Catalog::Distribution::EntryItem < ::Catalog::EntryItem

  attr_accessor :geographic_name_classification

  def initialize(params = {})
    super(**params)
    geographic_name_classification
    true
  end

  def html_helper
    :otu_catalog_entry_item_tag
  end

  # @return [Boolean]
  def linked_to_valid_taxon_name?
    object.taxon_name&.is_valid? 
  end

  def data_attributes
    base_data_attributes.merge(
      'history-otu-taxon-name-id' => taxon_name_global_id,
      'history-is-valid' => linked_to_valid_taxon_name?
    )
  end

  def taxon_name_global_id
    object&.taxon_name&.to_global_id&.to_s
  end

  def geographic_name_classification
    case object.class.base_class.name
    when "AssertedDistribution"
      @geographic_name_classification ||= object.geographic_area.geographic_name_classification
    when "TypeMaterial"
      @geographic_name_classification ||= object.collection_object.geographic_name_classification
    when "CollectionObject"
      @geographic_name_classification ||= object.geographic_name_classification
    end
    @geographic_name_classification ||= {country: nil, state: nil, county: nil}
  end

  def country
    @geographic_name_classification[:country]
  end

  def state
    @geographic_name_classification[:state]
  end

  def county
    @geographic_name_classification[:county]
  end

end

