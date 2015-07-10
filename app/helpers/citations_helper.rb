module CitationsHelper

  def citation_tag(citation)
    return nil if citation.nil?
    citation_string = (citation.source.author_year.nil? ? content_tag(:span, 'author, year not yet provided for source', class: :subtle) : citation.source.author_year)
    str = [citation.citation_object.class.name, ": ", object_tag(citation.citation_object.metamorphosize), " in ", citation_string].join
    str = str + " (pages #{citation.pages})" if !citation.pages.blank?
    str.html_safe
  end

  def citation_link(citation)
    return nil if citation.nil?
    link_to(citation_tag(citation).html_safe, citation.citation_object.metamorphosize)
  end

  def citations_search_form
    render('/citations/quick_search_form')
  end

  def add_citation_link(object: object, attribute: nil)
    link_to('Add citation', new_citation_path(citation: {
        citation_object_type: object.class.base_class.name,
        citation_object_id: object.id})) if object.has_citations?
  end

  def edit_citation_link(citation)
    edit_object_link(citation)
  end

  # @return [True]
  #   indicates a custom partial should be used, see list_helper.rb
  def citations_recent_objects_partial
    true 
  end



end
