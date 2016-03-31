module NomenclatureCatalog

  class EntryItem 
    attr_accessor :nomenclature_date
    attr_accessor :object
    attr_accessor :object_class

    def initialize(object, nomenclature_date)
      @object = object
      @object_class =  cited_class
      @nomenclature_date = nomenclature_date
    end

    def cited? 
      object.class.name == 'Citation' 
    end

    def citation
      cited? ? object : nil
    end

    def source
      object.source 
    end

    def cited_class  
      if citation 
        citation.annotated_object.class.name 
      else
        object.class.name
      end
    end

  end
end
