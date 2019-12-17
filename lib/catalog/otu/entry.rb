# A Catalog::Entry has many entry items.  Together CatalogEntrys form a Catalog
class Catalog::Otu::Entry < ::Catalog::Entry

  def initialize(otu)
    super(otu)
    true
  end

  def build
    from_self
    true
  end

  def to_html_method
    :otu_catalog_entry_item_to_html
  end

  def from_self
    a = ::Otu.coordinate_otus(object.id).load

    # It's just this OTU, and it's never been cited, 
    # or cross-referenced to another name, etc.
    if a.size == 1 && object.citations.none?
      @items << Catalog::Otu::EntryItem.new(
        object: object,
        base_object: object,
      )
    end

    a.each do |o|
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
