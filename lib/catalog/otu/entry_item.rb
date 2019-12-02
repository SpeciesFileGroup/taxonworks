
class Catalog::Otu::EntryItem < ::Catalog::EntryItem

  # @return [String]
  def origin
    'otu'
  end

  def html_helper
    :otu_catalog_entry_item_tag
  end

end

