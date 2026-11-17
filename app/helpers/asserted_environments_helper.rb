module AssertedEnvironmentsHelper
  def label_for_asserted_environment(asserted_environment)
    return nil if asserted_environment.nil?

    asserted_environment.uri_label
  end

  def asserted_environment_tag(asserted_environment)
    return nil if asserted_environment.nil?

    content_tag(:span, safe_join([
      asserted_environment.uri_label,
      ': ',
      object_tag(asserted_environment.asserted_environment_object)
    ]))
  end

  def asserted_environment_autocomplete_tag(asserted_environment, term = nil)
    mark_tag(asserted_environment_tag(asserted_environment), term)
  end

  def asserted_environment_autoselect_tag(asserted_environment, term = nil)
    asserted_environment_autocomplete_tag(asserted_environment, term)
  end

  def asserted_environment_autoselect_info(asserted_environment)
    [Vendor::Envo.local_id(asserted_environment.uri)]
  end

  def asserted_environments_search_form
    render('/asserted_environments/quick_search_form')
  end
end
