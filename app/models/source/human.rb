class Source::Human < Source

  has_many :roles
  has_many :source_source_roles, class_name: 'SourceSource', as: :role_object
  has_many :people, through: :source_source_roles, source: :person

  #TODO set cached values!
  before_save :set_cached_values

  def authority_name
    # TODO need to use full last name with suffix not just last_name
    case  self.people.count
      when 0
        return ('')  # is this even a valid case?
       when 1
        return (people[0].last_name)
      else
        p_array = Array.new
        for i in 0..(self.people.count-1) do
          p_array.push(self.people[i].last_name)
        end
        p_array.to_sentence(:last_word_connector =>' & ')
    end
  end
  protected

  def set_cached_values
    self.cached_author_string = authority_name
    # TODO what should the cached (full ref string) be?
  end
end
