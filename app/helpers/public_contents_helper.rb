module PublicContentsHelper

  def public_content_renderer(public_content, style = :default)

    case style.to_sym
    when :default
      MARKDOWN_HTML.render(public_content.text).html_safe  
    when :linked_otu # only link OTU

    when :linked_all

    end
  end

  def foo
  end

end
