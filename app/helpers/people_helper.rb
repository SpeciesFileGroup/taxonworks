module PeopleHelper

  def self.person_tag(person)
    return nil if person.nil?
    person.name
  end

  def person_tag(person)
    PeopleHelper.person_tag(person)
  end

  def people_search_form
    render('/people/quick_search_form')
  end

  def person_link(person)
    return nil if person.nil?
    link_to(PeopleHelper.person_tag(person).html_safe, person)
    # todo: @mjy This causes test to fail, no 'select_person_path'
    # l = link_to(person.name, select_person_path(person))
    # person.id == sessions_current_person_id ?
    #     content_tag(:mark, l) :
    #     l
  end

end
