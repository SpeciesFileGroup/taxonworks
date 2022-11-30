module PublicContentsHelper

  LINK_REGEX = Regexp.new('\[(.*)\]\(\/(otus|sources|taxon_names)\/(\d+)\)')

  def public_content_renderer(public_content, style = :default)

    t  = public_content.text

    if style
      case style.to_sym
      when :linked_otu # only link OTU
        r = Regexp.new('\[(.*)\]\(\/(sources|taxon_names)\/(\d+)\)')
        t.gsub!(r, '\1')
      when :none
        t.gsub!(LINK_REGEX, '\1')
      else
        # do nothing
      end
    end

    MARKDOWN_HTML.render(t).html_safe
  end

  private

  # TODO, provide options for generating labels

end
