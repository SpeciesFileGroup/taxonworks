module DocumentationHelper

  def documentation_tag(documentation)
    return nil if documentation.nil?
    string = [documentation.documentation_object_type, ': ',
              object_tag(documentation.documentation_object)].join.html_safe
    string
  end

  def documentation_link(documentation)
    return nil if documentation.nil?
    link_to(documentation_tag(documentation).html_safe, documentation)
  end

  def document_viewer_target(object)
    viewer_documents(object).first
  end

  def viewer_documents(object)
    document_ids = []

    sessions_current_user.pinboard
    #  pinboard - top document
    #  pinboard -

    #    So- behaviour.
    #    We need to allow the user to choose a document to show.
    #    That document should be, in order of priority:
    #    1) the pinned Doucment that is_inserted = true
    #  2) the pinned Document
    #  3) the pinned Source that is_inserted (if it has a PDF)
    #  4) the pinned Source (if it has a PDF)
    #  If there is none of 1-4 you get help message saying what to do OR we just don’t display the slide out. I could
    # write a boolean returning method to dtermine if any of 1-4 are available.
    #    Just thought of another thing on way in - If a record has a citation, then the source for that Citation should
    # be pre-loaded (assuming source has PDF)


  end

  # @param [Object] object
  def document_toggle_tag(object) # TODO: Apparently unused...
    content_tag(:div, class: 'document_toggle_tag') do
      viewer_documents.each do |document_id|
        # content_tag(:span, link_to(content_tag(Document.find(document_id), '/view/pdf/link/or/onclick')))
      end
    end
  end

end
