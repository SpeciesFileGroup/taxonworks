module ProtocolRelationshipsHelper
  def protocol_relationship_tag(protocol_relationship)
    return nil if protocol_relationship.nil?
    protocol_tag(protocol_relationship.protocol) + ': ' + object_tag(protocol_relationship.protocol_relationship_object)
  end

  def label_for_protocol_relationship(protocol_relationship)
    return nil if protocol_relationship.nil?
    label_for_protocol(protocol_relationship.protocol) + ': ' + label_for(protocol_relationship.protocol_relationship_object)
  end

  def protocol_relationship_link(protocol_relationship)
    return nil if protocol_relationship.nil?
    link_to(protocol_relationship_tag(protocol_relationship), protocol_relationship)
  end

  def protocol_relationships_search_form
    render('/protocol_relationships/quick_search_form')
  end
end
