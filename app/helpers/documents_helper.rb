module DocumentsHelper

  def document_tag(document)
    return nil if document.nil?
    document.document_file_file_name
  end

  def document_link(document)
    return nil if document.nil?
    link_to(document_tag(document).html_safe, document)
  end

  def documents_search_form
    render('/documents/quick_search_form')
  end

end
