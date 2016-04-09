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
    taxon_name_classification.classification_label
  end

  # @return [link]
  
  def taxon_name_classification_link(taxon_name_classification)
    return nil if taxon_name_classification.nil?
    link_to(taxon_name_classification_tag(taxon_name_classification).html_safe, metamorphosize_if(taxon_name_classification.taxon_name))
  end

  # @return [String]
  #   a span summarizing taxon name classification
  def taxon_name_classification_status_tag(taxon_name)
    content_tag(:span, class: :classification_status) do
      if taxon_name.unavailable_or_invalid? 
        TaxonNameClassification.where_taxon_name(@taxon_name).with_type_array(ICZN_TAXON_NAME_CLASSIFICATION_NAMES + ICN_TAXON_NAME_CLASSIFICATION_NAMES).collect{|c| 
          content_tag(:span, c.classification_label, class: 'brief_status') 
        }.join('; ').html_safe
      else
        content_tag(:span, 'Valid', class: 'brief_status') 
      end
    end
  end 

  # @return [True]
  #   indicates a custom partial should be used, see list_helper.rb
  def taxon_name_classifications_recent_objects_partial
    true 
  end

  


end
