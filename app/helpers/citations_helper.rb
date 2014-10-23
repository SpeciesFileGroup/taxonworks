
module CitationsHelper

  def self.citation_tag(citation)
    return nil if citation.nil?
    
  end

  def citation_tag(citation)
    return nil if citation.nil?
    citation_string = (citation.source.author_year.nil? ? citation.source.author_year : content_tag(:span, 'author, year not yet provided for source', class: :subtle))
    str = [citation.citation_object.class.name, ": ", object_tag(citation.citation_object.metamorphosize), " in ", citation_string].join
    str.html_safe
  end

  def citation_link(citation)
    return nil if citation.nil?
    link_to(CitationsHelper.citation_tag(citation).html_safe, citation.citation_object)
  end

  def citations_search_form
    render('/citations/quick_search_form')
  end

end
