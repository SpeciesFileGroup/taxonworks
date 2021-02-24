# Shared helpers for catalog rendering.  Params should "generic, i.e. targeting annotations almost exclusively."
module Lib::CatalogHelper

  # @return [String, nil]
  def history_topics(citation)
    return nil if citation.nil?
    if t = citation.citation_topics.collect{|t| controlled_vocabulary_term_tag(t.topic)}.join.html_safe
      content_tag(:span, t, class: 'history__citation_topics')
    else
      nil
    end
  end

  # @return [String, nil]
  #    pages from the citation, with prefixed :
  def history_pages(citation)
    return nil if citation.nil?
    str = citation.source.year_suffix.to_s
    str += ": #{citation.pages}." if citation.pages
#    content_tag(:span, str, class: 'history__pages') unless str.blank?
    unless str.blank?
      link_to(content_tag(:span, str, title: citation.source.cached, class: 'history__pages'), send(:nomenclature_by_source_task_path, source_id: citation.source.id) )
    end
  end

  # @return [String, nil]
  #   any Notes on the citation in question 
  def history_citation_notes(citation)
    return nil if citation.nil? || !citation.notes.any?
    content_tag(:span, citation.notes.collect{|n| note_tag(n)}.join.html_safe, class: 'history__citation_notes') 
  end

  def history_in(source)
    return nil if source.nil?
    return content_tag(:span,  content_tag(:em, ' in ') + source_author_year_tag(source), class: [:history__in])
  end

  protected

  # @return [String, nil]
  #    a computed css class, when provided indicates that the citation is the original citation for the object provided
  def original_citation_css(object, citation)
    return nil if citation.nil?
    'history__original_description' if citation.is_original? && object == citation.citation_object
  end
end
