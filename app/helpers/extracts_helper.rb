module ExtractsHelper

  # TODO: reference identifiers/origin objects etc.
  def extract_tag(extract)
    return nil if extract.nil?
    e = []

    if extract.old_objects.any?
      e.push ' from: '
      e.push extract.old_objects.collect{|o| object_link(o) } 
    else
      "#{extract.id} (no origin)"
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
