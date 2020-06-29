# A Catalog::EntryItem corresponds to a single row in the catalog.  It can be thought of as a chronological entry typically 1:1 with some Citation.
class Catalog::EntryItem

  # The visualized element of this entry item, e.g. the subject taxon name of a taxon name relationship
  attr_accessor :base_object

  # The source of this entry item, e.g. a TaxonNameRelationship
  attr_accessor :object

  # Optional, should be provided explicitly 
  attr_accessor :citation

  # @return [Time, nil]
  #   can be explicitly assigned, or derived from object.nomenclature_date if not provided
  # Date from the name perspective (e.g. sorted by original publication date)
  # See also citation_date
  attr_accessor :nomenclature_date

  # @return [String]
  # Source.year_suffix
  attr_accessor :year_suffix

  # @return [String]
  # Source.pages
  attr_accessor :pages

  # @return [Symbol]
  #   a pointer to a method in /app/helpers 
  attr_accessor :to_html_method

  #
  # Computed/cached attributes, built on `build` of Entry
  #
  # @return [Boolean]
  #   See Catalog::Entry#first_item?
  attr_accessor :is_first

  # @return [Boolean]
  #   See Catalog::Entry#last_item?
  attr_accessor :is_last

  # @return [Boolean]
  #   does this match the target Entry
  attr_accessor :matches_current_target

  # @param [Hash] args
  def initialize(object: nil, base_object: nil, citation: nil, nomenclature_date: nil, year_suffix: nil, pages: nil, citation_date: nil, current_target: nil)
    raise if object.nil?
    @object = object
    @base_object = base_object 
    @nomenclature_date = nomenclature_date
    @year_suffix = citation.try(:source).try(:year_suffix)
    @pages =  citation.try(:source).try(:pages)
    @citation = citation
    @matches_current_target = current_target
  end

  def html_helper
    :object_tag
  end

  def base_data_attributes
    {
      'history-origin' => origin,
      'history-object-id' => object.to_global_id.to_s,
      'history-year' => nomenclature_date&.year || 'unknown',
      'history-is-first' => is_first,
      'history-is-last' => is_last, 
      'history-is-cited' => (citation ? true : false),
      'history-is-current-target' => matches_current_target
    }
  end

  def references_self?
    object == base_object 
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

  # @return [String]
  #  do not update with base_class
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
      t += citation.topics 
    end
    t.uniq
  end

  # TODO: optimize indecies so this is not needed.
  def in_source?(target_source)
    source == target_source
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
