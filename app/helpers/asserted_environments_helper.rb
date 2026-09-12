module AssertedEnvironmentsHelper
  def label_for_asserted_environment(asserted_environment)
    return nil if asserted_environment.nil?

    asserted_environment.uri_label
  end

  def asserted_environment_tag(asserted_environment)
    return nil if asserted_environment.nil?

    content_tag(:span, asserted_environment.uri_label)
  end

  def asserted_environment_autoselect_tag(asserted_environment, term = nil)
    mark_tag(asserted_environment_tag(asserted_environment), term)
  end

  def asserted_environment_autoselect_info(asserted_environment)
    [asserted_environment.uri]
  end
end
