# A Catalog Entry contains the metadata for a "single" collection object
# Mutiple CatalogEntries would make up a catalog.
class Catalog::CollectionObject::Entry

  # Each item is a line item in the CatalogEntry, i.e.
  # a bit of metadata about one specific item (not a list of items in the catalog)
  attr_accessor :items

  # The collection object referenced in this entry
  attr_accessor :reference_collection_object

  # @param [Hash] args
  def initialize(collection_object = nil)
    @items = []
    @reference_collection_object = collection_object
  end

  # @return [Array] of NomenclatureCatalog::EntryItem
  #   sorted by date provided
  def ordered_by_date
    now = Time.now
    items.sort{|a,b| [(a.start_date || now), a.object_class_name, a.type ] <=> [(b.start_date || now), b.object_class_name, b.type ] }
  end

end
