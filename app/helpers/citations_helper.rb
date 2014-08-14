module CitationsHelper

  def self.citation_tag(citation)
    return nil if citation.nil?
    citation.citation_object_type
  end

  def citation_tag(citation)
    CitationsHelper.citation_tag(citation)
  end

  def citation_link(citation)
    return nil if citation.nil?
    link_to(CitationsHelper.citation_tag(citation).html_safe, citation)
  end

  def citations_search_form
    render('/citations/quick_search_form')
  end

end
