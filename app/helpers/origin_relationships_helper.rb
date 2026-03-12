module OriginRelationshipsHelper
  def origin_relationship_tag(origin_relationship)
    return nil if origin_relationship.nil?
    "#{object_tag(origin_relationship.old_object)}: #{object_tag(origin_relationship.new_object)}"
  end

  def origin_relationship_link(origin_relationship)
    return nil if origin_relationship.nil?
    link_to(origin_relationship_tag(origin_relationship).html_safe, origin_relationship)
  end
end
