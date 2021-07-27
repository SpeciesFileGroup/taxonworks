module BiologicalAssociationsHelper

  def biological_association_tag(biological_association)
    return nil if biological_association.nil?
    object_tag(biological_association.biological_association_subject) + ' ' + content_tag(:span, biological_relationship_tag(biological_association.biological_relationship), class: :notice) + ' ' +
      object_tag(biological_association.biological_association_object)
  end

  def biological_association_link(biological_association)
    return nil if biological_association.nil?
    link_to(object_tag(biological_association.biological_association_subject).html_save, biological_association.biological_association_subject) + ' ' +
      link_to(content_tag(:span, biological_relationship_tag(biological_association.biological_relationship), class: :notice).html_save, biological_association) + ' ' +
      link_to(object_tag(biological_association.biological_association_object).html_save, biological_association)
    #link_to(biological_association_tag(biological_association).html_safe, biological_association)
  end

  # def biological_associations_search_form
  #   render('/biological_associations/quick_search_form')
  # end

end
