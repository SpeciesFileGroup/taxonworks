module NamespacesHelper

  def namespace_tag(namespace)
    return nil if namespace.nil?
    namespace.name
  end

  def namespace_link(namespace)
    return nil if namespace.nil?
    link_to(NamespacesHelper.namespace_tag(namespace).html_safe, namespace)
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

end
