module DocumentsHelper

  def document_tag(document)
    return nil if document.nil?
    string = [ document.cached,  document.verbatim_label, document.print_label, document.document_label, document.field_notes, document.to_param].compact.first
    string
  end

  def document_link(document)
    return nil if document.nil?
    link_to(document_tag(document).html_safe, document)
  end

  def documents_search_form
    render('/documents/quick_search_form')
  end

end
