module ExtractsHelper
  def extract_tag(extract)
    return nil if extract.nil?
    extract.verbatim_anatomical_origin    
  end

  def extract_link(extract)
    return nil if extract.nil?
    link_to(extract_tag(extract).html_safe, extract)
  end

  def extracts_search_form
    render('/extracts/quick_search_form')
  end
end
