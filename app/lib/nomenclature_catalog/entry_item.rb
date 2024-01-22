module NomenclatureCatalog

  # Is 1:1 with a Citation
  class EntryItem

    attr_accessor :object

    # Optional
    attr_accessor :citation

    # Date from the name perspective (e.g. sorted by original publication date)
    # See also citation_date
    attr_accessor :nomenclature_date

    # Date from the citation perspective (e.g. the date when the assertion in this entry was published)
    # See also nomenclature_date
    attr_accessor :citation_date

    # Required
    attr_accessor :taxon_name

    # @param [Hash] args
    def initialize(object: nil, taxon_name: nil, citation: nil, nomenclature_date: nil, citation_date: nil)
      raise if object.nil? || taxon_name.nil?
      # raise if nomenclature_date.nil? && !(object.class.to_s == 'Protonym' || 'Combination' || 'TaxonNameRelationship')

      @object = object
      @taxon_name = taxon_name
      @nomenclature_date = nomenclature_date
      @citation_date = citation_date
      @citation = citation
    end

    # @return [Boolean]
    def cited?
      !citation.nil? # object.class.name == 'Citation'
    end

    # @return [Source, nil]
    def source
      citation.try(:source)
    end

    # @return [Date]
    def nomenclature_date
      @nomenclature_date.nil? ? object.nomenclature_date : @nomenclature_date
    end

    # @return [None]
    def citation_date
    end

    # @return [String]
    def object_class
      object.class.name
    end

    # @return [Regex::Match]
    def from_relationship?
      object_class =~ /^TaxonNameRelationship/
    end


    # @return [Boolean]
    def is_subsequent?
 #     object == taxon_name && !citation.try(:is_original?)
      object == taxon_name && !citation.nil? && !citation.is_original?
    end

    # @return [String]
    def other_name
      if from_relationship?
        ([object.subject_taxon_name, object.object_taxon_name] - [taxon_name]).first
      end
    end

    # @return [String]
    def origin
      case object_class
      when 'Protonym'
        'protonym'
      when 'Hybrid'
        'hybrid'
      when 'Combination'
        'combination'
      when /TaxonNameRelationship/
        'taxon_name_relationship'
      else
        'error'
      end
    end

    # @return [Boolean]
    def is_valid_name?
      object_class == 'Protonym' && object.is_valid?
    end

    protected

    # @return [String]
    def cited_class
      if citation
        citation.annotated_object.class.name
      else
        object.class.name
      end
    end

  end
end
