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
    person_tag(person) + ' ' + person_timeframe_tag(person) + ' ' + person_used_tag(person)
  end

  def person_timeframe_tag(person)
    content_tag(:span, class: :subtle) do 
      (person_lived_tag(person) + ' ' + person_active_tag(person)).html_safe
    end.html_safe
  end

  def person_lived_tag(person)
    'lived: ' + [person.year_born || '?', person.year_died || '?'].join('-') 
  end

  def person_active_tag(person)
    return ('active: ' + content_tag(:i, 'unknown')).html_safe if person.year_active_start.nil? && person.year_active_end.nil?

    ae = person.year_active_end
    ae = nil if !ae.nil? && ae == person.year_active_start

    'active ~ ' + [ person.year_active_start || '?', ae || '?'].join('-')
  end

  def person_used_tag(person)
    t = person.roles.count
    content_tag(:span, class: [:subtle, :tiny_space,  (t > 0 ? :success : :warning ) ]) do
      t > 0 ? "#{person.roles.count} #{"use".pluralize(t)}" : 'unused'
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
