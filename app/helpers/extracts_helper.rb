module ExtractsHelper

  # TODO: reference identifiers/origin objects etc.
  def extract_tag(extract)
    return nil if extract.nil?
    if a = simple_identifier_list_tag(extract)
      return a
    else
      extract.verbatim_anatomical_origin || extract.id.to_s
    end
  end

  def extract_link(extract)
    return nil if extract.nil?
    link_to(extract_tag(extract), extract)
  end

  def extracts_search_form
    render('/extracts/quick_search_form')
  end
end
