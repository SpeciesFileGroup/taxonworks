module TaxonNameClassificationsHelper

  def taxon_name_classification_tag(taxon_name_classification)
    return nil if taxon_name_classification.nil?
    full_taxon_name_tag(taxon_name_classification.taxon_name) + ' (' + taxon_name_classification.classification_label + ')'
  end

  def label_for_taxon_name_classification(taxon_name_classification)
    return nil if taxon_name_classification.nil?
    label_for_taxon_name(taxon_name_classification.taxon_name) + ' (' + taxon_name_classification.classification_label + ')'
  end

  def taxon_name_classification_link(taxon_name_classification)
    return nil if taxon_name_classification.nil?
    link_to(taxon_name_classification_tag(taxon_name_classification).html_safe, metamorphosize_if(taxon_name_classification.taxon_name))
  end

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

  # @return [String]
  #   a span summarizing taxon name classification
  def taxon_name_classification_status_tag(taxon_name)
    if !taxon_name.is_valid? # taxon_name.unavailable_or_invalid?  
      values = TaxonNameClassification.where_taxon_name(taxon_name).with_type_array(ICZN_TAXON_NAME_CLASSIFICATION_NAMES + ICN_TAXON_NAME_CLASSIFICATION_NAMES).collect{|c|
        c.classification_label}.uniq.sort

        content_tag(:span, "Is an  #{values.to_sentence} name.", class: [:brief_status], data: [ 'icon-alert' ])  
    else
      content_tag(:span, 'Is a valid name.', class: [:brief_status, :passed])  
    end 
  end 

  # @return [True]
  #   indicates a custom partial should be used, see list_helper.rb
  def taxon_name_classifications_recent_objects_partial
    true 
  end


end
