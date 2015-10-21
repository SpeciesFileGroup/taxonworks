module ContentsHelper

  # Note disambiguation from Rails' content_tag()
  def taxon_works_content_tag(content)
    return nil if content.nil?
    content.text
  end

  def content_link(content)
    return nil if content.nil?
    link_to(taxon_works_content_tag(content).html_safe, content)
  end

  def contents_search_form
    render('/contents/quick_search_form')
  end

end
