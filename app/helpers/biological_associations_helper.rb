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

  def simple_hash(biological_associations)
    h = []

    biological_associations.each do |b|
      types = biological_relationship_types(b.biological_relationship)

      r = %I{order family genus}.inject({}) { |hsh, r| hsh[('subject_' + r.to_s).to_sym] = [b.biological_association_subject.taxonomy[r.to_s]].flatten.compact.join(' '); hsh }
       r.merge!(
        # types: biological_relationship_types(b.biological_relationship),
        subject: label_for(b.biological_association_subject),
        subject_properties: types[:subject].join('|').presence,
        biological_relationships: label_for(b.biological_relationship),
        object_properties: types[:object].join('|').presence,
        object: label_for(b.biological_association_object),
      )

       r.merge! %I{order family genus}.inject({}) { |hsh, r| hsh[('object_' + r.to_s).to_sym] = [b.biological_association_object.taxonomy[r.to_s]].flatten.compact.join(' '); hsh }
     h.push r
    end

    h
  end

end
