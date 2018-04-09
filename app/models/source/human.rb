# A human source can be either a single individual person or a group of people (e.g. Tom, Dick and
# Harry decided that this species is the same as that but haven't written it up yet.)
class Source::Human < Source

  has_many :source_source_roles, class_name: 'SourceSource', as: :role_object
  has_many :people, through: :source_source_roles, source: :person, validate: true

  accepts_nested_attributes_for :people

  validate :at_least_one_person_is_provided

  # @return [String]
  def authority_name
    Utilities::Strings.authorship_sentence(
      people.collect{|p| p.last_name}
    )
  end

  # @param [Source] source
  # @return [Boolean]
  def similar(source)
    false
  end

  # @param [Source] source
  # @return [Boolean]
  def identical(source)
    false
  end

  protected

  # @return [Ignored]
  def set_cached
    update_column(:cached, authority_name)
  end

  # @return [Ignored]
  def at_least_one_person_is_provided
    if people.size < 1 # size not count
      errors.add(:base, 'at least one person must be provided')
    end
  end
end
