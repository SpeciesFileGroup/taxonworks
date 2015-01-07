module TaxonNameClassificationsHelper

  def taxon_name_classification_options(taxon_name)
    o = [] 
    case taxon_name.rank_class.nomenclatural_code 
    when :icn 
      o = ICN_TAXON_NAME_CLASSIFICATION_HASH 
    when :iczn 
      o =  ICZN_TAXON_NAME_CLASSIFICATION_HASH
    end
    options_for_select(o)
  end

  def taxon_name_classification_tag(taxon_name_classification)
    return nil if taxon_name_classification.nil?
    taxon_name_classification.type_class.class_name
  end

end
