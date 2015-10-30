module BiologicalRelationshipsHelper

  def biological_association_tag(biological_relationship)
    return nil if biological_relationship.nil?
    biological_relationship.name
  end

  def biological_relationship_link(biological_association)
    return nil if biological_relationship.nil?
    link_to(biological_relationship_tag(biological_relationship).html_safe, biological_association)
  end

  def biological_relationships_search_form
    render('/biological_relationships/quick_search_form')
  end

end
