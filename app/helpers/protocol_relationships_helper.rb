module ProtocolRelationshipsHelper
  def protocol_relationship_tag(protocol_relationship)
    return nil if protocol_relationship.nil?
    "Protocol relationship #{protocol_relationship.id}"
  end

  def protocol_relationship_link(protocol_relationship)
    return nil if protocol_relationship.nil?
    link_to(protocol_relationship_tag(protocol_relationship), protocol_relationship)
  end

  def protocol_relationships_search_form
    render('/protocol_relationships/quick_search_form')
  end
end
