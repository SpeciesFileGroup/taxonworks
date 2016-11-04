module NomenclatureCatalog
  class CatalogEntry
    attr_accessor :items
    attr_accessor :topics
    attr_accessor :reference_taxon_name

    def initialize(taxon_name = nil)
      @items = []
      @reference_taxon_name = taxon_name
    end

    def ordered_by_nomenclature_date
      items.sort{|a,b| (a.nomenclature_date || Time.utc(1)) <=> (b.nomenclature_date || Time.utc(1))}
    end

    def source_list
      sources = items.collect{|i| i.source}
      if !reference_taxon_name.nil?
        relationship_items.each do |i|
          if i.object.subject_taxon_name == reference_taxon_name
            sources.push i.object.object_taxon_name.origin_citation.try(:source)
          elsif i.object.object_taxon_name == reference_taxon_name
            sources.push i.object.subject_taxon_name.origin_citation.try(:source)
          else
            # should NOT hit this point 
          end
        end
      end
      sources.compact.uniq.sort_by{|a| a.cached}
    end

    def relationship_items
      items.select{|i| i.object_class =~ /TaxonNameRelationship/}
    end

    def topics_for_source(source)
      topics = []
      items.each do |i|
        topics += i.object.topics if i.source == source
      end
      topics.uniq
    end

    def topics
      @topics ||= set_topics
      @topics
    end

    def set_topics
      topics = []
      items.each do |i|
      end
    end

  end
end
