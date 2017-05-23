module CollectionObjectCatalog

  # A Catalog Entry contains the metadata for a "single" collection object
  # Mutiple CatalogEntries would make up a catalog.  
  class CatalogEntry
  
    # Each item is a line item in the Entry 
    attr_accessor :items

    # All sources crossreferenced in this record
    attr_accessor :sources

    # Topics are extracted from each item and cached here
    attr_accessor :topics
  
    # All observed dates for this entry
    attr_accessor :dates

    # The taxon name being referenced in this entry (think of it as the header) 
    attr_accessor :reference_collection_object

    def initialize(collection_object = nil)
      @items = []
      @reference_collection_object = collection_object
    end

    # @return [Array of NomenclatureCatalog::EntryItem]
    #   sorted by date provided
    def ordered_by_date
      now = Time.now
      items.sort{|a,b| [(a.start_date || now), a.object_class, a.type ] <=> [(b.start_date || now), b.object_class, b.type ] }
    end

    # @return [Array of Topics]
    #   an extraction of all Topics referenced in citations that
    #   were observed in this CatalogEntry for the source 
    def topics_for_source(source)
      topics = []
      items.each do |i|
        topics += i.object.topics if i.source == source
      end
      topics.uniq
    end

    def topics
      @topics ||= all_topics
      @topics
    end

    def date_range
      [dates.first, dates.last].compact
    end

    def dates
      @dates ||= all_dates
      @dates
    end

    def sources 
      @sources ||= all_sources
      @sources
    end

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

   protected 

    def all_dates
    end

    def all_topics
    end

  end
end
