module DocumentationHelper

  def documentation_tag(documentation)
    return nil if documentation.nil?
    string = [documentation.documentation_object_type, ': ',
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
    type = document_file_content_type 
    link_to("download #{type}", documentation.document.document_file.url()) 
  end

  def documentation_links(object)
    object.documentations.collect{ |o| documentation_download_link(o)}.join(", ").html_safe
  end

end
