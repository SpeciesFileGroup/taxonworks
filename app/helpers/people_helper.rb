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

  # @param use_count [Integer, nil]
  #   this person's total role count - nil is treated as 0
  # @param role_types [Array<String>]
  #   this person's distinct Role subclass names
  # @param in_project [Boolean]
  #   whether this person is used in the current project
  def person_autocomplete_tag(
    person, term = nil,
    use_count: nil, role_types: [], in_project: false
  )
    return nil if person.nil?
    s = [
      person_tag(person),
      person_timeframe_tag(person),
      person_used_tag(use_count:, role_types:),
      person_project_membership_tag(in_project:)
    ].compact.join(' ')
    mark_tag(s, term)
  end

  def person_timeframe_tag(person)
    content_tag(
      :span,
      class: [ :feedback, 'feedback-secondary', 'feedback-thin' ]
    ) do
      (person_lived_tag(person) + ' ' + person_active_tag(person)).html_safe
    end.html_safe
  end

  def person_lived_tag(person)
    'lived: ' + [person.year_born || '?', person.year_died || '?'].join('-')
  end

  def person_project_membership_tag(in_project: false)
    return nil unless in_project
    content_tag(
      :span,
      'In&nbsp;Project'.html_safe,
      class: [:feedback, 'feedback-thin', 'feedback-success']
    )
  end

  def person_active_tag(person)
    return ('active: ' + content_tag(:i, 'unknown')).html_safe if person.year_active_start.nil? && person.year_active_end.nil?

    ae = person.year_active_end
    ae = nil if !ae.nil? && ae == person.year_active_start

    'active ~ ' + [ person.year_active_start || '?', ae || '?'].join('-')
  end

  def person_used_tag(use_count: nil, role_types: [])
    count = use_count || 0

    if count == 0
      return content_tag(
        :span,
        'unused',
        class: [:feedback, 'feedback-thin', 'feedback-danger']
      )
    end

    types = role_types
      .map(&:safe_constantize).compact
      .collect(&:human_name).join(', ')

    content_tag(
        :span,
        "#{count} #{"use".pluralize(count)}",
        class: [:feedback, 'feedback-thin', 'feedback-primary'],
        data: {count:}
      ) +
      ' ' +
      content_tag(
        :span,
        types,
        class: [:feedback, 'feedback-thin', 'feedback-secondary']
      )
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
