
class Catalog::EntryItem

 # The focus of this entry item
  # ?! is this an attribute of Catalog::Entry
  attr_accessor :base_object # was taxon_name

  # The focus of this entry item
  attr_accessor :object
  
  # Optional
  attr_accessor :citation

  # @return [Time, nil]
  #   can be explicitly assigned, or derived from object.nomenclature_date if not provided
  # Date from the name perspective (e.g. sorted by original publication date)
  # See also citation_date
  attr_accessor :nomenclature_date

  attr_accessor :to_html_method

  # @param [Hash] args
  def initialize(object: nil, base_object: nil, citation: nil, nomenclature_date: nil, citation_date: nil)
    raise if object.nil? # || base_object.nil? # will we always need double context? probably not
     
    # raise if nomenclature_date.nil? && !(object.class.to_s == 'Protonym' || 'Combination' || 'TaxonNameRelationship')

    @object = object
    @base_object = base_object 
    @nomenclature_date = nomenclature_date
    @citation = citation
  end

  def html_helper
    :object_tag
  end

  def base_data_attributes
    {
      'history-origin' => origin,
      'history-object-id' => object.id,
    }
  end

  # See Subclasses for extensions
  def data_attributes
    base_data_attributes
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
    return @nomenclature_date if @nomenclature_date
    if object.respond_to?(:nomenclature_date)
      object.nomenclature_date
    else
      nil
    end
  end

  # TODO: just base class ..
  
  # @return [String]
  def object_class
    object.class.name
  end

  # @return [String]
  def origin
    case object_class
    when /TaxonNameRelationship/
      'taxon_name_relationship'
    else
      object_class.tableize.singularize.humanize.downcase
    end
  end

  # @return [Array of Topic] 
  #   the topics on this object for this Citation/Source combination *only*
  def topics
    t = []
    if source
      t += object.topics 
    end
    t.uniq
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
