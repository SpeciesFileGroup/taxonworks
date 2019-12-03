# Shared helpers for catalog rendering.  Params should "generic, i.e. targeting annotations almost exclusively."
module Lib::CatalogHelper

  def history_topics(citation)
    return nil if citation.nil?
    content_tag(:span, Utilities::Strings.nil_wrap(' [', citation.citation_topics.collect{|t| t.topic.name}.join(', '), ']'), class: 'history__citation_topics')
  end

  # @return [String, nil]
  #    pages from the citation, with prefixed :
  def history_pages(citation)
    return nil if citation.nil?
    content_tag(:span, ": #{citation.pages}.", class: 'history__pages') if citation.pages
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
