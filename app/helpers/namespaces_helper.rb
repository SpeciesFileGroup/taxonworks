module NamespacesHelper

  def namespace_tag(namespace)
    return nil if namespace.nil? || !namespace.persisted?
    namespace.short_name + ': ' + namespace.name
  end

  def namespace_autocomplete_tag(namespace)
    return nil if namespace.nil?
    r = []

    if namespace.verbatim_short_name.blank?
      r.push namespace.short_name
    else
      r.push content_tag(:span, '[' + namespace.verbatim_short_name + ']', class: [:feedback, 'feedback-thin', 'feedback-warning'] )
    end

    r.push content_tag(:span, namespace.name, class: [:feedback, 'feedback-thin', 'feedback-primary'] )

    if !namespace.institution.blank?
      r.push content_tag(:span, namespace.institution, class: [:feedback, 'feedback-thin', 'feedback-secondary'] )
    end

    r.join('<br/>').html_safe
  end

  def namespace_link(namespace)
    return nil if namespace.nil?
    link_to(namespace_tag(namespace).html_safe, namespace)
  end

  def namespaces_search_form
    render('/namespaces/quick_search_form')
  end

  def namespace_select_tag(namespace_element)
    select_tag(namespace_element,
               options_for_select(Namespace.pluck(:short_name).uniq),
               prompt: 'Select a namespace')
  end
end
