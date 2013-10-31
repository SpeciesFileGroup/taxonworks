class Source::Human < Source

  has_many :roles
  has_many :source_source_roles, class_name: 'Role::SourceSource', as: :role_object
  has_many :people, through: :source_source_roles, source: :person


end
