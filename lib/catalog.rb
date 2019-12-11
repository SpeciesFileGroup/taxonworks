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

  # @return [Hash]
  def sources_to_json
    h = {
      list: {},
      year_metadata: ::Catalog.year_metadata(sources, items) 
    }
    
    sources.each do |s|
      h[:list][s.metamorphosize.to_global_id.to_s] = {
        cached: s.cached,
        objects: objects_for_source(s).collect{|o| o.object.to_global_id.to_s } 
      }
    end
    h
  end

  def topics_to_json
    h = {
      list: {},
      year_metadata: {} #  ::Catalog.topic_metadata(entries) 
    }

    topics.each do |t|
      h[:list][t.metamorphosize.to_global_id.to_s] = {
        name: t.name,
        css_color: t.css_color,
        objects: [] #  TODO!
      }
    end
    h
  end

  def self.topic_metadata(entry_list)
    h = {}
    entry_list.each do |d|
      if h[d.year]
        h[d.year] += 1
      else
        h[d.year] = 1
      end
    end
    h
  end

  # @return [Hash]
  def self.year_metadata(source_list, item_list)
    ::Catalog.year_hash(
      ::Catalog.all_dates(source_list, item_list)
    )
  end

  # @return [Hash]
  def self.year_hash(date_list)
    h = {}
    date_list.each do |d|
      if h[d.year]
        h[d.year] += 1
      else
        h[d.year] = 1
      end
    end
    h
  end

  # @return [Array]
  #  do not uniq! used in counts
  def self.all_dates(source_list, item_list)
    d = []
    source_list.each do |s|
      d.push s.nomenclature_date # was cached_nomenclature_date (a Date)
    end

    item_list.each do |i|
      d.push i.nomenclature_date
    end

    d.compact.uniq.sort
  end

end
