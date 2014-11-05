module CitationsHelper

  def citation_tag(citation)
    return nil if citation.nil?
    citation_string = (citation.source.author_year.nil? ? content_tag(:span, 'author, year not yet provided for source', class: :subtle) : citation.source.author_year )
    str = [citation.citation_object.class.name, ": ", object_tag(citation.citation_object.metamorphosize), " in ", citation_string].join
    str.html_safe
  end

  def citation_link(citation)
    return nil if citation.nil?
    link_to(citation_tag(citation).html_safe, citation.citation_object.metamorphosize)
  end

  def citations_search_form
    render('/citations/quick_search_form')
  end

  def add_citation_link(object: object)
    if object.citable?
    link_to("Cite this #{object.class.name}", new_citation_path(alternate_value: {citation_object_type:      object.class.base_class.name,
                                                                                  citation_object_id:        object.id }))
    else
      nil
    end
  end

end
