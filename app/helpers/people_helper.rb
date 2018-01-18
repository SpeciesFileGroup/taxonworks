module PeopleHelper

  def person_tag(person)
    return nil if person.nil?
    if person.new_record?
      person.bibtex_name 
    else
      person.cached ? person.cached : 'CACHED VALUE NOT BUILT, CONTACT AN ADMIN.'
    end
  end

  def people_search_form
    render('/people/quick_search_form')
  end

  def person_link(person)
    return nil if person.nil?
    link_to(person_tag(person), person.metamorphosize)
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
