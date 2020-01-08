class Catalog::Otu::EntryItem < ::Catalog::EntryItem

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

end

