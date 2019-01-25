module NamespacesHelper

  def namespace_tag(namespace)
    return nil if namespace.nil? || !namespace.persisted?
    namespace.short_name + ': ' + namespace.name
  end

  def namespace_autocomplete_tag(namespace)
    return nil if namespace.nil?
    a = [
      (namespace.institution.blank? ? nil : ( [content_tag(:span, namespace.institution, class: :subtle), '<br>'].join.html_safe  )),
      namespace.short_name,
      (namespace.verbatim_short_name.blank? ? nil : content_tag(:span, '[' + namespace.verbatim_short_name + ']', class: :warning ).html_safe ),
      content_tag(:span, namespace.name,  class: :subtle )
    ].compact.join(' ').html_safe
  end

  def namespace_link(namespace)
    return nil if namespace.nil?
    link_to(namespace_tag(namespace).html_safe, namespace)
  end

  def namespaces_search_form
    render('/namespaces/quick_search_form')
  end

  def namespace_from_identifier_tag(identifier)
    if identifier.respond_to?(:namespace)
      namespace_tag(identifier.namespace)
    else
      nil
    end
  end

  def namespace_select_tag(namespace_element)
    select_tag(namespace_element,
               options_for_select(Namespace.pluck(:short_name).uniq),
               prompt: 'Select a namespace')
  end
end
