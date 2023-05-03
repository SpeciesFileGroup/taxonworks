module CitationsHelper

  def citation_tag(citation)
    return nil if citation.nil?
    [citation.citation_object.class.name, ': ', object_tag(citation.citation_object&.metamorphosize), ' in ', citation_source_body(citation)].compact.join.html_safe
  end

  def label_for_citation(citation)
    return nil if citation.nil?
    [citation.citation_object.class.name, ': ', label_for(citation.citation_object&.metamorphosize), ' in ', citation_source_body_label(citation)].compact.join.html_safe
  end

  # @return [String]
  #   Author year, pages, topics
  #   presently contains HTML
  def citation_source_body(citation)
    [
      [source_author_year_tag(citation.source) + citation.source.year_suffix.to_s, citation.pages].compact.join(':'),
      citation_topics_tag(citation)
    ].compact.join(' ').html_safe
  end

# @return [String]
  #   Author year, pages, topics
  #   presently contains HTML
  def citation_source_body_label(citation)
    [
      [source_author_year_label(citation.source) + citation.source.year_suffix.to_s,
       citation.pages].compact.join(':'),
      citation_topics_label(citation)
    ].compact.join(' ')
  end

  def citation_topics_label(citation)
    return nil unless citation.topics.any?
    [
      '[',
      citation.citation_topics.collect{|ct|
        label_for_controlled_vocabulary_term(ct.topic.metamorphosize) + (!ct.pages.blank? ? ": #{ct.pages}" : '')
      }.compact.join(', '),
      ']'
    ].join
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

  def citations_tag(object)
    object.citations.collect{|c| [source_author_year_tag(c.source) + c.source.year_suffix.to_s, c.pages].compact.join(': ')}.to_sentence
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

  def quick_citation_tag(source_id, object, klass = nil)
    content_tag(:span, 'Cite', data: {source_id: source_id, global_id: object.to_global_id.to_s, quick_citation: true}, class: klass)
  end

end
