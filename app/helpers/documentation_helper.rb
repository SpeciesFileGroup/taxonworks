module DocumentationHelper

  def documentation_tag(documentation)
    return nil if documentation.nil?
    string = [
      documentation.documentation_object_type, ': ',
      object_tag(documentation.documentation_object)].join.html_safe
    string
  end

  def documentation_link(documentation)
    return nil if documentation.nil?
    link_to(documentation_tag(documentation), documentation).html_safe
  end

  def document_viewer_target(object)
    viewer_documents(object).first
  end

  def documentation_download_link(documentation)
    return nil if documentation.nil?
    link_to(
      document_type_label(documentation.document),
      documentation.document.document_file.url(),
      title: documentation.document.document_file_file_name,
      data: {icon: :download} ) 
  end

  def documentation_download(documentation)
    return nil if documentation.nil?
    link_to(
      '',
      documentation.document.document_file.url(),
      class: ['circle-button', 'btn-download'],
      download: documentation.document.document_file_file_name,
      title: documentation.document.document_file_file_name) 
  end

  def documentation_links(object)
    object.documentation.where('documentation.project_id = ?', sessions_current_project_id).collect{ |o| documentation_download_link(o)}.join("&nbsp;|&nbsp;")&.html_safe
  end

  def document_viewer_buttons(object)
    object.documentation.where('documentation.project_id = ?', sessions_current_project_id).collect{ |o| document_viewer_button(o.document)}.join("&nbsp;|&nbsp;")&.html_safe
  end

end
