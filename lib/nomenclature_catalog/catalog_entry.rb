module NomenclatureCatalog

  # A Catalog Entry contains the metadata the nomenclatural history of a single "reference" taxon name.
  # Mutiple CatalogEntries would make up a catalog.
  class CatalogEntry

    # Each item is a line item in the Entry
    attr_accessor :items

    # Topics are extracted from each item and cached here
    attr_accessor :topics

    # All observed dates for this entry
    attr_accessor :dates

    # All sources
    attr_accessor :sources

    # The taxon name being referenced in this entry (think of it as the header)
    attr_accessor :reference_taxon_name

    def initialize(taxon_name = nil)
      @items = []
      @reference_taxon_name = taxon_name
    end

    # @return [Array of NomenclatureCatalog::EntryItem]
    #   sorted by date, then taxon name name as rendered for this item
    def ordered_by_nomenclature_date
      now = Time.now
      items.sort{|a,b| [(a.nomenclature_date || now), a.object_class, a.taxon_name.cached_original_combination.to_s ] <=> [(b.nomenclature_date || now), b.object_class, b.taxon_name.cached_original_combination.to_s ] }
    end

    # @return [Array of EntryItems]
    #    only those entry items that reference a TaxonNameRelationship
    def relationship_items
      items.select{|i| i.object_class =~ /TaxonNameRelationship/}
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

    def names
      @names ||= all_names
      @names
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

    def item_names(catalog_item)
      [reference_taxon_name, catalog_item.taxon_name, catalog_item.other_name].compact.uniq
    end

    def all_names
      n = [ reference_taxon_name]
      items.each do |i|
        n.push item_names(i)
      end
      n.flatten.uniq.sort_by!(&:cached)
      n
    end

    # @return [Array of Sources]
    #   as extracted for all EntryItems, orderd alphabetically by full citation
    def all_sources
      s  = items.collect{|i| i.source}
      if !reference_taxon_name.nil?
        relationship_items.each do |i|
          s.push i.object.object_taxon_name.origin_citation.try(:source)  if i.object.subject_taxon_name != reference_taxon_name
          s.push i.object.subject_taxon_name.origin_citation.try(:source) if i.object.object_taxon_name != reference_taxon_name
        end
      end
      s.compact.uniq.sort_by {|a| a.cached}
    end

    def all_dates
      d = []
      sources.each do |s|
        d.push s.cached_nomenclature_date
      end

      items.each do |i|
        d.push i.nomenclature_date
      end
      d.compact.sort
    end

    def all_topics
      t = []
      sources.each do |s|
        t.push topics_for_source(s)
      end
      t.flatten.uniq.compact.sort
    end

  end
end
