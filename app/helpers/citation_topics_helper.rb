module CitationTopicsHelper

  def citation_topic_tag(citation_topic)
      

    return nil if citation_topic.nil?
    citation = citation_topic.citation
    citation_string = (
      (citation.source.type == 'Source::Bibtex' && citation.source.try(:author_year)) ? 
      citation.source.author_year : 
      content_tag(:span, 'author, year not yet provided for source', class: :subtle) 
    )

    str = [citation_topic.topic.name, ': ', object_tag(citation.citation_object.metamorphosize).html_safe, ' in ', citation_string].join
    str = str + ": #{citation.pages}." if !citation.pages.blank?
    str.html_safe

  end
end
