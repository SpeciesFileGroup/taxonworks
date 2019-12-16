class Catalog::Nomenclature::EntryItem < ::Catalog::EntryItem
  
  def initialize(object: nil, base_object: nil, citation: nil, nomenclature_date: nil, citation_date: nil) 
    super
  end

  def html_helper
    :nomenclature_catalog_entry_item_tag
  end

  # @return [Regex::Match]
  def from_relationship?
    object_class =~ /^TaxonNameRelationship/
  end

  # @return [String]
  def other_name
    if from_relationship?
      ([object.subject_taxon_name, object.object_taxon_name] - [base_object]).first
    end
  end

  # @return [Boolean]
  def is_valid_name?
    object_class == 'Protonym' && object.is_valid?
  end

  # @return [Boolean]
  #   this is the MM result.  Only return true 
  #   when the protonym that is the focus of the Entry
  #   is referenced in the EntryItem
  def is_current_name?
    case object_class
    when 'Protonym'
      return object.id == base_object.id
    when 'Combination'
      object.combination_taxon_names.each do |p|
        return true if p.id == object.id # maybe object?!
      end
      return false
    else
      if from_relationship?
        # Technically we only want misspellings here?
        return true if object_class =~ /Misspelling/
      end
      return false
    end 
  end

  def data_attributes
    base_data_attributes.merge(
      'history-is-valid' => is_valid_name?,
      'history-is-current-name' => is_current_name?
    )
  end

end
