module NomenclatureCatalog

  # Is 1:1 with a Citation 
  class EntryItem 

    attr_accessor :object

    # Optional
    attr_accessor :citation 

    # Provide a nomenclature data if available, if it is
    # not provided 
    attr_accessor :nomenclature_date

    attr_accessor :taxon_name

    def initialize(object: nil, taxon_name: nil, citation: nil, nomenclature_date: nil)
      raise if object.nil? || taxon_name.nil?
      raise if nomenclature_date.nil? && !(object.class == 'Protonym' || 'Combination' || 'TaxonNameRelationship')

      @object = object
      @taxon_name = taxon_name
      @nomenclature_date = nomenclature_date
      @citation = citation
    end

    def cited? 
      !citation.nil? # object.class.name == 'Citation' 
    end

    def source
      citation.try(:source)
    end

    def nomenclature_date
      @nomenclature_date.nil? ? object.nomenclature_date : @nomenclature_date
    end

    def object_class
      object.class.name
    end

    def is_subsequent?
      object == taxon_name && !citation.try(:is_original?)
    end

    protected

    def cited_class  
      if citation 
        citation.annotated_object.class.name 
      else
        object.class.name
      end
    end

  end
end
