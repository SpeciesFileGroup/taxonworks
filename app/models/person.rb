class Person < ActiveRecord::Base

  validates_presence_of :last_name, :type
  before_validation :set_type_if_blank
  validates :type, inclusion: { in: ['Person::Vetted', 'Person::Unvetted'],
                                message: "%{value} is not a valid type" }

  has_many :roles 
  has_many :author_roles, class_name: 'Role::SourceAuthor'
  has_many :editor_roles, class_name: 'Role::SourceAuthor'
  has_many :authored_sources, through: :author_roles, source: :role_object, source_type: 'Source::Bibtex'  
  has_many :edited_sources, through: :editor_roles, source: :role_object, source_type: 'Source::Bibtex'  

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

end

