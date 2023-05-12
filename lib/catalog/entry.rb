# A Catalog::Entry has many entry items.  Together Catalog::Entries form a Catalog
#
# !! Make sure to add a dependency for all Entry types to the bottom of this file
# !! or `build` may not inherit correctly (would otherwise need to be above `def initialize`
class Catalog::Entry

  # The target object(s) for this entry
  attr_accessor :object

  # @return [Array]
  # Each item is a line item in the Entry
  attr_accessor :items

  # @return [Hash]
  #   { global_id => [EntryItem] }
  # An index of all the EntryItems by global_id taken from "object"
  attr_accessor :item_index

  # @return [Array]
  # All observed dates for this entry
  attr_accessor :dates

  # @return [Array]
  # All Sources observed for this entry
  attr_accessor :sources

  # @return [Array]
  # All Topics observed for this entry
  attr_accessor :topics

  # @return [Array]
  #   of strings, the array determines nesting order
  #   all entries in the catalog should have `sorts` of the same length
  #   !! Not yet implemented !!
  attr_accessor :sort_order

  def initialize(object, sort_order = [])
    @object = object
    @items = []
    @sort_order = sort_order
    build
    index_items
  end

  # Redefined in subclasses!
  # !! This is default only, it should be (re)defined in subclasses.
  def build
    @items << Catalog::EntryItem.new(object: object, citation: object.origin_citation)
    true
  end

  def index_items
    items.each do |i|
      i.is_first = first_item?(i)
      i.is_last = last_item?(i)
    end
    true
  end

  # @return Boolean
  # Named "first` to avoid conflice with `citation#is_original`
  # Returns true if
  #   * it's the only item with this object
  #   * the citation is_original
  #   * there is no original citation in any item for this object, and it's the first in the list chronologically
  # Inversely, returns false (in all other cases):
  #   * its not the only one item with this object
  #   * it doesn't have a citation that is_original
  #   * there is no indication of the original citaiton, and the item isn't first in the list chronologically
  def first_item?(item)
    o = items_by_object(item.object)
    return true if o.size == 1
    return true if item.citation&.is_original?
    return true if !original_citation_present? && o.index(item) == 0

    false
  end

  # @return Boolean
  # Returns true if
  #   * it's the only item with this object
  #   * it's the last citation chronologically
  # Inversely, returns false in all other cases:
  def last_item?(item)
    o = items_by_object(item.object)
    return true if o.size == 1
    return true if o.last == item

    false
  end

  def original_citation_present?
    items.each do |i|
      return true if i.citation&.is_original
    end
    false
  end

  def items_by_object(object)
    ::Catalog.chronological_item_sort( items.select{|i| i.object == object } )
  end

  # @return [Array of NomenclatureCatalog::EntryItem]
  #   sorted by date, then taxon name name as rendered for this item
  def ordered_by_nomenclature_date
    ::Catalog.chronological_item_sort(items)
  end

  # @param [Source] source
  # @return [Array of Topics]
  #   an extraction of all Topics referenced in citations that
  #   were observed in this CatalogEntry for the source
  #   TODO: SET/BUILD?
  def topics_for_source(source)
    topics = []
    items.each do |i|
      # topics += i.object.topics if i.source == source
      topics += i.topics if i.source == source
    end
    topics.uniq
  end

  # @return [Scope]
  def topics
    @topics ||= all_topics
    @topics
  end

  # @return [Array]
  def date_range
    [dates.first, dates.last].compact
  end

  # @return [Array]
  def dates
    @dates ||= all_dates
    @dates
  end

  # @return [Array]
  def sources
    @sources ||= all_sources
    @sources
  end

  # @return [Hash]
  def year_hash
    h = {}
    dates.each do |d|
      if h[d.year]
        h[d.year] += 1
      else
        h[d.year] = 1
      end
    end
    h
  end

  def to_json
    return {
      item_count: items.count,
    }
  end

  def is_subsequent_entry_item?(entry_item)
  end

  def coordinate_entry_items
  end

  def citations
    @citations ||= all_citations
    @citations
  end

  protected

  # @return [Array of Source]
  #
  # Here .source is item.source, not item.object.source, i.e.
  # it comes from a specific citation, not one of many citations
  # for the object.
  #
  # !! Redefined in some subclasses
  def all_sources
    items.collect{|i| i.source}.compact
  end

  def all_citations
    items.map(&:citation).compact
  end

  # @return [Array]
  # Some duplication here
  def all_dates
    d = []
    sources.each do |s|
      d.push s.nomenclature_date # was cached_nomenclature_date (a Date)
    end

    items.each do |i|
      d.push i.nomenclature_date
    end

    d.compact.uniq.sort
  end

  # @return [Array of Topics]
  def all_topics
    t = []
    sources.each do |s|
      t.push topics_for_source(s)
    end
    t.flatten.uniq.compact.sort
  end
end

require_dependency Rails.root.to_s + '/lib/catalog/nomenclature/entry.rb'
require_dependency Rails.root.to_s + '/lib/catalog/otu/entry.rb'
require_dependency Rails.root.to_s + '/lib/catalog/distribution/entry.rb'
