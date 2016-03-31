module NomenclatureCatalog
  class CatalogEntry
    attr_accessor :items

    def initialize
      @items = []
    end

    def ordered_by_nomenclature_date
      items.sort{|a,b| a.nomenclature_date <=> b.nomenclature_date } 
    end

    def source_list
      items.collect{|i| i.source}.compact.uniq.sort_by{|a| a.cached} 
    end

    def topics_for_source(source)
      topics = []
      items.each do |i|
        topics += i.object.topics if i.source == source
      end
      topics.uniq
    end

  end
end
