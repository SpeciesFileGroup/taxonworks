module OriginRelationshipsHelper
  def origin_relationship_tag(origin_relationship)
    return nil if origin_relationship.nil?
    "#{object_tag(origin_relationship.old_object)}: #{object_tag(origin_relationship.new_object)}"
  end

  def origin_relationship_autocomplete_selected_tag(origin_relationship)
    origin_relationship_tag(origin_relationship)
  end
  
  def origin_relationships_search_form
    render('/origin_relationships/quick_search_form')
  end

  def origin_relationship_link(origin_relationship)
    return nil if origin_relationship.nil?
    link_to(origin_relationship_tag(origin_relationship).html_safe, origin_relationship)
  end
end
