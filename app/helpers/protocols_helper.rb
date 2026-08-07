module ProtocolsHelper
  def protocol_tag(protocol)
    return nil if protocol.nil?
    protocol.name
  end

  def label_for_protocol(protocol)
    return nil if protocol.nil?
    protocol.name
  end

  def protocol_link(protocol)
    return nil if protocol.nil?
    link_to(protocol_tag(protocol).html_safe, protocol)
  end    

  def protocols_search_form
    render('/protocols/quick_search_form')
  end

  def protocol_autocomplete_selected_tag(protocol)
    return nil if protocol.nil?
    protocol_tag(protocol)
  end

  def add_protocol_link(object: nil, attribute: nil)
    link_to('Add protocol', new_protocol_relationship_path(protocol_relationship: {
      protocol_object_type: object.class.base_class.name,
      protocol_object_id: object.id,
      protocol_object_attribute: attribute})) if object.has_protocols?
  end

end
