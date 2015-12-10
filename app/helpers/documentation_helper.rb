module DocumentationHelper

  def documentation_tag(documentation)
    return nil if documentation.nil?
    string = [ documentation.cached,  documentation.verbatim_label, documentation.print_label, documentation.document_label, documentation.field_notes, documentation.to_param].compact.first
    string
  end

  def documentation_link(documentation)
    return nil if documentation.nil?
    link_to(documentation_tag(documentation).html_safe, documentation)
  end

  def documentation_search_form
    render('/documentation/quick_search_form')
  end

end
