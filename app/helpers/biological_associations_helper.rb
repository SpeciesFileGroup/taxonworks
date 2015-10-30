module BiologicalAssociationsHelper

  def biological_association_tag(biological_association)
    return nil if biological_association.nil?
    biological_association.name
  end

  def biological_association_link(biological_association)
    return nil if biological_association.nil?
    link_to(biological_association_tag(biological_association).html_safe, biological_association)
  end

  def biological_associations_search_form
    render('/biological_associations/quick_search_form')
  end

end
