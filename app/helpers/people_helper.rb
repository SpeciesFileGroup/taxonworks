module PeopleHelper

  def person_tag(person)
    return nil if person.nil?
    person.name
    person.cached ? person.cached : 'WARNING CACHE NOT BUILT ADMIN TEST'
  end

  def people_search_form
    render('/people/quick_search_form')
  end

  def person_link(person)
    return nil if person.nil?
    link_to(person_tag(person), person.metamorphosize)
  end

  # @return [String]
  #   a formatted list of people
  def people_names(people)
    people.collect{ |a| a.full_last_name }.to_sentence(last_word_connector: ' & ')
  end

end
