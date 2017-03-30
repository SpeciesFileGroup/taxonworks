module ContentsHelper

  # Note disambiguation from Rails' content_tag()
  def taxon_works_content_tag(content)
    return nil if content.nil?
    content_tag(:span) do
      [
        topic_tag(content.topic).html_safe,
        otu_tag(content.otu).html_safe
      ].join(' - ').html_safe
    end
  end

  def content_link(content)
    return nil if content.nil?
    link_to(taxon_works_content_tag(content).html_safe, content)
  end

  def contents_search_form
    render('/contents/quick_search_form')
  end

end
