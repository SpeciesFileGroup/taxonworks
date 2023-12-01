module BiologicalAssociationsHelper

  def biological_association_tag(biological_association)
    return nil if biological_association.nil?
    object_tag(biological_association.biological_association_subject) + ' ' + content_tag(:span, biological_relationship_tag(biological_association.biological_relationship), class: :notice) + ' ' +
      object_tag(biological_association.biological_association_object)
  end

  def biological_association_link(biological_association)
    return nil if biological_association.nil?
    link_to(object_tag(biological_association.biological_association_subject).html_safe, biological_association.biological_association_subject.metamorphosize) + ' ' +
      link_to(content_tag(:span, biological_relationship_tag(biological_association.biological_relationship), class: :notice).html_safe, biological_association) + ' ' +
      link_to(object_tag(biological_association.biological_association_object).html_safe, biological_association.biological_association_object.metamorphosize)
    #link_to(biological_association_tag(biological_association).html_safe, biological_association)
  end

  def family_by_genus_summary(scope)
    r = { }

    scope.find_each do |o|
      i = o.biological_association_subject.taxonomy

      j = o.biological_association_object.taxonomy

      gk = i['kingdom'] || 'unknown'
      g = i['genus']&.compact&.join(' ') || 'unknown'

      fk = j['kingdom'] || 'unknown'
      f = j['family'] || 'unknown'

      r[gk] ||= {}
      r[gk][g] ||= {}
      r[gk][g][fk] ||= {}
      r[gk][g][fk][f] ||= 0
      r[gk][g][fk][f] += 1
    end

    r
  end


end
