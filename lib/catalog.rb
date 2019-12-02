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

end
