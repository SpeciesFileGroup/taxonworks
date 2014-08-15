module PeopleHelper

  def self.person_tag(person)
    return nil if person.nil?
    person.name
  end

  def person_tag(person)
    PeopleHelperHelper.person_tag(person)
  end

  def person_search_form
    render('/projects/quick_search_form')
  end

  def person_link(person)
    return nil if person.nil?
    l = link_to(person.name, select_person_path(person))
    person.id == sessions_current_person_id ?
        content_tag(:mark, l) :
        l
  end

end
