module CitationsHelper

  def citation_tag(citation)
    return nil if citation.nil?
    citation_string = citation_author_year(citation)
    [citation.citation_object.class.name, ': ', object_tag(citation.citation_object&.metamorphosize), ' in ', citation_source_body(citation)].compact.join.html_safe
  end

  def citation_source_body(citation)
    pages = citation.pages unless citation.pages.blank?
    [[citation_author_year(citation), pages].compact.join(':'), citation_topics_tag(citation)].compact.join(' ').html_safe
  end

  def citation_topics_tag(citation)
    return nil unless citation.topics.any?
    [
      '[',
      citation.citation_topics.collect{|ct|
      content_tag(:span, (controlled_vocabulary_term_tag(ct.topic.metamorphosize) + (!ct.pages.blank? ? ": #{ct.pages}" : '')), class: [:annotation__citation_topic])
    }.compact.join(', '),
      ']'
    ].join.html_safe
  end

  def citation_author_year(citation)
    if citation.source && citation.source.type == 'Source::Bibtex' && citation.source.author_year.present?
      citation.source.author_year
    else
      content_tag(:span, 'Author, year not yet provided for source.', class: :subtle)
    end
  end

  def citation_annotation_tag(citation)
    content_tag(:span, citation_source_body(citation), class: [:annotation__citation])
  end

  def citation_list_tag(object)
    return nil unless object.has_citations? && object.citations.any?
    content_tag(:h3, 'Citations') +
      content_tag(:ul, class: 'annotations__citation_list') do
      object.citations.collect{|t|
        content_tag(:li, citation_annotation_tag(t))
      }.join.html_safe
    end
  end

  # Used in browse/catalog, try to deprecate
  def citation_author_year_tag(citation)
    return nil if citation.nil?
    case citation.source.type
    when 'Source::Verbatim'
      citation.source.verbatim
    when 'Source::Bibtex'
      citation.source.author_year
    else
      'NOT PROVIDED/CACHE ERROR'
    end
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

  # @return [True]
  #   indicates a custom partial should be used, see list_helper.rb
  def citations_recent_objects_partial
    true
  end

  def attributes_for_citation_object(citation)
    render
  end

end
