module PeopleHelper

  def person_tag(person)
    return nil if person.nil?
    person.name
  end

  def people_search_form
    render('/people/quick_search_form')
  end

  def person_link(person)
    return nil if person.nil?
    link_to(person_tag(person), person.metamorphosize)
  end

end
