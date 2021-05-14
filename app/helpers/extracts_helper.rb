module ExtractsHelper

  # TODO: reference identifiers/origin objects etc.
  def extract_tag(extract)
    return nil if extract.nil?
    e = []

    if a = simple_identifier_list_tag(extract)
      e.push a
    end

    if extract.origin
      e.push 'from:'
      e.push origin&simple_identifier_list_tag(extract.origin) 
    end

    e.push "Extract " + extract.id.to_s if e.empty?

    e.join.html_safe 
  end

  def extract_link(extract)
    return nil if extract.nil?
    link_to(extract_tag(extract), extract)
  end

  def extracts_search_form
    render('/extracts/quick_search_form')
  end

end
