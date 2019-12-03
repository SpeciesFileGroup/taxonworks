# A Catalog is a series of catalog entries, which in turn have entry items. The model more or less represents a two level 
class Catalog

  # Each Object is the basis for an Entry
  attr_accessor :catalog_targets

  attr_accessor :entries

  # @return Boolean
  attr_accessor :compile

  # @return Boolean
  attr_accessor :built

  def initialize(targets:)
    @catalog_targets = targets 
    @entries = []
    build 
  end

  def build
    @built = false
  end

  def reference_object_global_id
    if catalog_targets.size == 1
      catalog_targets.first.to_global_id.to_s
    else
      nil
    end
  end

  def reference_object_valid_taxon_name_global_id
    if catalog_targets.size == 1
      o = catalog_targets.first
      if o.class.name == 'Otu'
        return o.taxon_name&.get_valid_taxon_name&.to_global_id.to_s
      elsif o.class.name == 'Protonym'
        return o.get_valid_taxon_name&.to_global_id.to_s
      end
    end
    nil
  end

  def items
    entries&.collect{|e| e.items}&.flatten || []
  end

  def items_chronologically
    Catalog.chronological_item_sort(items)
  end

  def entries_sorted
    # TODO: sort!
  end

  def entry_sort_valid?
    i = entries.first&.sort_order
    entries.each do |e|
      return false if e.sort_order.size != i
    end
    true
  end

  def self.chronological_item_sort(entry_items)
    now = Time.now
    entry_items.sort{|a,b| [(a.nomenclature_date || now) ] <=> [(b.nomenclature_date || now) ] }
  end

  # @return [Array of TaxonName]
  #   all topics observed in this catalog. For example the index.
  def topics
    t = []
    entries.each do |e|
      t += e.topics
    end   
    t.uniq
  end

  def sources
    t = []
    entries.each do |e|
      t += e.sources
    end
    t.uniq
  end

  # TODO: optimize ;)
  def objects_for_source(source)
    d = []

    items.each do |i|
      d << i if i.in_source?(source)
    end
    d.uniq
  end

end
