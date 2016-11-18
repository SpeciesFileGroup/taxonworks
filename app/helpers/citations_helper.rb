module CitationsHelper


  def citation_tag(citation)
    return nil if citation.nil?
    citation_string = (
      (citation.source.type == 'Source::Bibtex' && citation.source.try(:author_year)) ? 
      citation.source.author_year : 
      content_tag(:span, 'author, year not yet provided for source', class: :subtle) 
    )
   
    str = [citation.citation_object.class.name, ": ", object_tag(citation.citation_object.metamorphosize).html_safe, " in ", citation_string].join
    str = str + ": #{citation.pages}." if !citation.pages.blank?
    if citation.citation_topics.any? 
      str = str + ' [' + citation.citation_topics.collect{|ct| ct.topic.name + (ct.pages? ? ": #{ct.pages}" : "")}.join(', ') + ']' 
    end
    str += '.' 
#    str += citation.is_original? ? ' ORIGINAL' : ' SUBSEQUENT'
    str.html_safe
  end

  def citation_link(citation)
    return nil if citation.nil?
    link_to(citation_tag(citation).html_safe, citation.citation_object.metamorphosize)
  end

  def citations_search_form
    render('/citations/quick_search_form')
  end

  def add_citation_link(object: nil, attribute: nil)
    link_to('Add citation', new_citation_path(citation: {
        citation_object_type: object.class.base_class.name,
        citation_object_id: object.id})) if object.has_citations?
  end

  def edit_citation_link(citation)
    edit_object_link(citation)
  end

  def citation_author_year_tag(citation)
    if !citation.nil?
      str = citation.source.author_year
      str.blank? ? 'NOT PROVIDED/CACHE ERROR' : str 
    end
  end

  # @return [True]
  #   indicates a custom partial should be used, see list_helper.rb
  def citations_recent_objects_partial
    true 
  end



end
