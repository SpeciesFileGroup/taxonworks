class Person < ActiveRecord::Base

  validates_presence_of :last_name, :type
  before_validation :set_type_if_blank, :type_is_vetted_or_unvetted

  has_many :roles 
  has_many :authored_sources, through: :roles, source: :role_object, source_type: 'Source::Bibtex'  

  def name 
    [self.first_name, self.suffix, self.last_name, self.postfix].compact.join(' ')
  end

  def is_author?
    self.authored_sources.to_a.length > 0
  end

  protected

  def set_type_if_blank
    self.type ||= 'Person::Unvetted'
  end

  # @return [Object]
  def type_is_vetted_or_unvetted
    if !['Person::Vetted', 'Person::Unvetted'].include?(self.type)
      errors.add(:type, 'Invalid type')
    end
  end

=begin
    if self.type == 'Person::Vetted' or 'Person::Unvetted'
      return true
    end
    # self.type == 'Person::Vetted' || 'Person::Unvetted'
=end

end

