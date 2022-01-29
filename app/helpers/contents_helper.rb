module ContentsHelper

  # Note disambiguation from Rails' content_tag()
  def taxon_works_content_tag(content)
    return nil if content.nil?
    content_tag(:span, title: content.text) do
      [ controlled_vocabulary_term_tag(content.topic.metamorphosize),
        otu_tag(content.otu)
      ].join(' - ').html_safe
    end
  end

  def content_link(content)
    return nil if content.nil?
    link_to(taxon_works_content_tag(content), content)
  end

  def contents_search_form
    render('/contents/quick_search_form')
  end

end
