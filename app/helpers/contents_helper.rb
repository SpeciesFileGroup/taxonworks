module ContentsHelper

  def self.content_tag(content)
    return nil if content.nil?
    content.text
  end

  # TODO: @mjy Have to resolve method_name conflict with tag_helper method 'content_tag'.
  # def content_tag(content)
  #   ContentsHelper.content_tag(content)
  # end
  #
  def content_link(content)
    return nil if content.nil?
    link_to(ContentsHelper.content_tag(content).html_safe, content)
  end

  def contents_search_form
    render('/contents/quick_search_form')
  end

end
