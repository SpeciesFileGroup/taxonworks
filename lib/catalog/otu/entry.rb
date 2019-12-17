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
        current_target: true # by definition?
      )
    end

    a.each do |o|
      matches_target = entry_item_matches_target?(o, object)

      o.citations.each do |c|
        @items << Catalog::Otu::EntryItem.new(
          object: o,
          base_object: object,
          citation: c,
          nomenclature_date: c.source&.cached_nomenclature_date,
          current_target: matches_target
        )
      end
    end
  end

  # @return [Boolean]
  #   this is the MM result
  def entry_item_matches_target?(item_object, reference_object)
    item_object.taxon_name_id == reference_object.taxon_name_id
  end

end
