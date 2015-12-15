module TaxonNameClassificationsHelper

  # @params[#taxon_name]
  def taxon_name_classification_options(taxon_name)
    o = []

    if taxon_name.rank_class

    case taxon_name.rank_class.nomenclatural_code
      when :icn
        o = ICN_TAXON_NAME_CLASSIFICATION_HASH
      when :iczn
        o =  ICZN_TAXON_NAME_CLASSIFICATION_HASH
      else # should never be hit ...
        o = ICZN_TAXON_NAME_CLASSIFICATION_HASH.merge(ICN_TAXON_NAME_CLASSIFICATION_HASH)
    end

    else # taxon_name is a new record
      o = ICZN_TAXON_NAME_CLASSIFICATION_HASH.merge(ICN_TAXON_NAME_CLASSIFICATION_HASH)
    end

    options_for_select(o)
  end

  def taxon_name_classification_tag(taxon_name_classification)
    return nil if taxon_name_classification.nil?
    taxon_name_classification.class_name
  end

  # @return [True]
  #   indicates a custom partial should be used, see list_helper.rb
  def taxon_name_classifications_recent_objects_partial
    true 
  end


end
