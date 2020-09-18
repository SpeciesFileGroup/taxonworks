module DocumentsHelper

  def document_tag(document)
    return nil if document.nil?
    document.document_file_file_name
  end

  def document_link(document)
    return nil if document.nil?
    link_to(document_tag(document).html_safe, document)
  end

  def document_viewer_button (document)
    return nil if document.nil?
    content_tag(:a,
      '',
      class: ['button-circle', 'pdf-button', 'button-default'],
      title: document.document_file_file_name,
      data: { pdfviewer: document.document_file.url() })
  end

  def document_download(document)
    return nil if document.nil?
    link_to(
      '',
      document.document_file.url(),
      class: ['circle-button', 'btn-download'],
      download: document.document_file_file_name,
      title: document.document_file_file_name) 
  end

  def documents_search_form
    render('/documents/quick_search_form')
  end

  def document_type_label(document)
    case document.document_file_content_type
    when 'application/pdf'
      'pdf'
    when 'application/octet-stream'
      'binary (Word or other)'
    when 'text/plain'
      'text'
    when 'text/xml'
      'xml'
    end
  end

end
