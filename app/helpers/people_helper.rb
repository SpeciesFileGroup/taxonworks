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

  # @return [String]
  #   a formatted list of people
  def people_names(people)
    people.collect{ |a| a.full_last_name }.to_sentence(last_word_connector: ' & ')
  end

end
