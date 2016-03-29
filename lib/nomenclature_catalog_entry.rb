class NomenclatureCatalogEntry

  attr_accessor :items

  def initialize
    @items = []
  end

  def ordered_by_nomenclature_date
    items.sort{|a,b| a.nomenclature_date <=> b.nomenclature_date } 
  end

  class NomenclatureCatalogItem
    attr_accessor :nomenclature_date
    attr_accessor :object

    def initialize(object, nomenclature_date)
      @object = object
      @nomenclature_date = nomenclature_date
    end

    def cited? 
      object.class.name == 'Citation' 
    end

    def citation
      cited? ? object : nil
    end

    def cited_class  
      if citation 
        citation.annotated_object.metamorphosize.class.name 
      else
        object.metamorphosize.class.name
      end
    end

  end

end
