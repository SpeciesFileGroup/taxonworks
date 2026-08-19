module PeopleHelper

  def person_tag(person)
    return nil if person.nil?
    if person.new_record?
      person.bibtex_name
    else
      person.cached ? person.cached : 'CACHED VALUE NOT BUILT, CONTACT AN ADMIN.'
    end
  end

  def label_for_person(person)
    return nil if person.nil?
    person.cached
  end

  def person_link(person)
    return nil if person.nil?
    link_to(person_tag(person), person.metamorphosize)
  end

  # @param role_counts [Hash{Integer => Integer}]
  #   `person.id => total role count`, e.g. from `Role.where(person_id: people.map(&:id)).group(:person_id).count`
  # @param role_types [Hash{Integer => Array<String>}]
  #   `person.id => distinct Role subclass names`, e.g. from
  #   `Role.where(person_id: people.map(&:id)).select(:person_id, :type).distinct.pluck(:person_id, :type)`,
  #   grouped by person_id
  # @param in_project_person_ids [Set<Integer>, #include?]
  #   ids of people used in the current project - e.g. `Person.project_use_counts(...).keys`
  def person_autocomplete_tag(person, term = nil, role_counts: {}, role_types: {}, in_project_person_ids: [])
    return nil if person.nil?
    s = [ person_tag(person),
      person_timeframe_tag(person),
      person_used_tag(person, role_counts:, role_types:),
      person_project_membership_tag(person, in_project_person_ids:)
    ].compact.join(' ')
    mark_tag(s, term)
  end

  def person_timeframe_tag(person)
    content_tag(:span, class: [ :feedback, 'feedback-secondary', 'feedback-thin' ]) do
      (person_lived_tag(person) + ' ' + person_active_tag(person)).html_safe
    end.html_safe
  end

  def person_lived_tag(person)
    'lived: ' + [person.year_born || '?', person.year_died || '?'].join('-')
  end

  def person_project_membership_tag(person, in_project_person_ids: [])
    return nil unless person && in_project_person_ids.include?(person.id)
    content_tag(:span, 'In&nbsp;Project'.html_safe, class: [:feedback, 'feedback-thin', 'feedback-success'])
  end

  def person_active_tag(person)
    return ('active: ' + content_tag(:i, 'unknown')).html_safe if person.year_active_start.nil? && person.year_active_end.nil?

    ae = person.year_active_end
    ae = nil if !ae.nil? && ae == person.year_active_start

    'active ~ ' + [ person.year_active_start || '?', ae || '?'].join('-')
  end

  def person_used_tag(person, role_counts: {}, role_types: {})
    count = role_counts.fetch(person.id, 0)

    return content_tag(:span, 'unused', class: [:feedback, 'feedback-thin', 'feedback-danger']) if count == 0

    types = role_types.fetch(person.id, []).map(&:safe_constantize).compact.collect(&:human_name).join(', ')

    content_tag(:span, "#{count} #{"use".pluralize(count)}", class: [:feedback, 'feedback-thin', 'feedback-primary'], data: {count:}) +
      ' ' +
      content_tag(:span, types, class: [:feedback, 'feedback-thin', 'feedback-secondary'])
  end

  def people_search_form
    render('/people/quick_search_form')
  end

  # @return [String, nil]
  #   A formatted list of people's last names
  #   TODO: deprecate for native call
  def people_names(people)
    Utilities::Strings.authorship_sentence( people.collect{ |a| a.full_last_name } )
  end

  def author_annotation_tag(author)
    return nil if author.nil?
    content_tag(:span, author.name, class: [:annotation__author])
  end

  def author_list_tag(object)
    return nil unless object.authors.any?
    content_tag(:h3, 'Authors') +
      content_tag(:ul, class: 'annotations_author_list') do
      object.authors.collect{|a| content_tag(:li, author_annotation_tag(a)) }.join.html_safe
    end
  end

  def editor_list_tag(object)
    return nil unless object.editors.any?
    content_tag(:h3, 'Editors') +
      content_tag(:ul, class: 'annotations_editor_list') do
      object.editors.collect{|a| content_tag(:li, author_annotation_tag(a)) }.join.html_safe
    end
  end

end
