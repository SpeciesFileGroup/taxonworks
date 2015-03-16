# A human source can be either a single individual person or a group of people (e.g. Tom, Dick and
# Harry decided that this species is the same as that but haven't written it up yet.)
class Source::Human < Source

  has_many :roles
  has_many :source_source_roles, class_name: 'SourceSource', as: :role_object
  has_many :people, through: :source_source_roles 

  accepts_nested_attributes_for :people

  validate :at_least_one_person_is_provided

  def authority_name
    last_names = people.collect{|p| p.last_name}
    last_names.to_sentence(last_word_connector: ' & ', two_words_connector: ' & ')
  end

  protected

  def set_cached
    self.cached = self.authority_name 
  end

  def at_least_one_person_is_provided
    if self.people.size == 0 # size not count
      errors.add(:base, 'at least one person must be provided')     
    end
  end
end
