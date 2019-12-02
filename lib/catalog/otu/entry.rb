# A Catalog::Entry has many entry items.  Together CatalogEntrys form a Catalog
class Catalog::Otu::Entry < ::Catalog::Entry
  
  def initialize(otu)
    super(otu)
  end

  def build
    from_self
    true
  end

  def to_html_method
    :otu_catalog_entry_item_to_html
  end

  def from_self
    ::Otu.coordinate_otus(object.id).each do |o|
      o.citations.each do |c|
        @items << Catalog::Otu::EntryItem.new(
          object: o,
          base_object: object,
          citation: c,
          nomenclature_date: c.source&.cached_nomenclature_date
        )
      end
    end 
  end

end
