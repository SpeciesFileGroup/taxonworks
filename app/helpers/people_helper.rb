module PeopleHelper

  def person_tag(person)
    return nil if person.nil?
    if person.new_record?
      person.bibtex_name 
    else
      person.cached ? person.cached : 'CACHED VALUE NOT BUILT, CONTACT AN ADMIN.'
    end
  end

  def person_link(person)
    return nil if person.nil?
    link_to(person_tag(person), person.metamorphosize)
  end

  def person_autocomplete_tag(person)
    return nil if person.nil?
    [ person_tag(person),
      person_timeframe_tag(person),
      person_used_tag(person),
      person_project_membership_tag(person)
    ].compact.join(' ')
  end

  def person_timeframe_tag(person)
    content_tag(:span, class: [ :feedback, 'feedback-secondary', 'feedback-thin' ]) do 
      (person_lived_tag(person) + ' ' + person_active_tag(person)).html_safe
    end.html_safe
  end

  def person_lived_tag(person)
    'lived: ' + [person.year_born || '?', person.year_died || '?'].join('-') 
  end

  def person_project_membership_tag(person)
    if person && person.respond_to?(:in_project_id) && person.in_project_id == sessions_current_project_id
      content_tag(:span, "In&nbsp;Project".html_safe, class: [:feedback, 'feedback-thin', 'feedback-success'])
    elsif person && person.used_in_project?(sessions_current_project_id)
      content_tag(:span, "In&nbsp;Project".html_safe, class: [:feedback, 'feedback-thin', 'feedback-success']) 
    else
      nil
    end
  end

  def person_active_tag(person)
    return ('active: ' + content_tag(:i, 'unknown')).html_safe if person.year_active_start.nil? && person.year_active_end.nil?

    ae = person.year_active_end
    ae = nil if !ae.nil? && ae == person.year_active_start

    'active ~ ' + [ person.year_active_start || '?', ae || '?'].join('-')
  end

  def person_used_tag(person)
    if person.respond_to?(:use_count)
      a = ''
      if person.use_count == 0
        a += content_tag(:span, 'unused', class: [:feedback, 'feedback-thin', 'feedback-danger'] )
      elsif person.use_count > 0
        a = a + content_tag(:span, "#{person.use_count} #{"use".pluralize(person.use_count)}", class: [:feedback, 'feedback-thin', 'feedback-primary'], data: {count: person.use_count}) + ' '
        a = a + content_tag(:span, "#{person.roles.pluck(:type).uniq.collect{|r| r.constantize.human_name}.join(', ')}", class: [:feedback, 'feedback-thin', 'feedback-secondary'] )
      else
        ''
      end
    else
      t = person.roles.load
      a = ''
      if t.count == 0
        a += content_tag(:span, 'unused', class: [:feedback, 'feedback-thin', 'feedback-danger'] )
      elsif t.count > 0
        a = a + content_tag(:span, "#{person.roles.size} #{"use".pluralize(t)}", class: [:feedback, 'feedback-thin', 'feedback-primary'], data: {count: t.count}) + ' '
        a = a + content_tag(:span, "#{person.roles.collect{|r| r.class.human_name}.uniq.join(', ')}", class: [:feedback, 'feedback-thin', 'feedback-secondary'] )
      else
        ''
      end
    end
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
