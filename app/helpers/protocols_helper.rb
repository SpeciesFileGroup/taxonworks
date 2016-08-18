module ProtocolsHelper
  def protocol_tag(protocol)
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
end
