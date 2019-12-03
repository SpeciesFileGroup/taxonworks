class Catalog::Otu::EntryItem < ::Catalog::EntryItem

  def html_helper
    :otu_catalog_entry_item_tag
  end

  def data_attributes
    base_data_attributes.merge(
      'history-otu-taxon-name-id' => taxon_name_global_id
    )
  end

  def taxon_name_global_id
    object&.taxon_name&.to_global_id&.to_s
  end

end

