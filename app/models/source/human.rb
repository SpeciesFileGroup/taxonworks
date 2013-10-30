class Source::Human < Source

  has_one :role
  has_one :source_source_role, class_name: 'Role::SourceSource', as: :role_object
  has_one :person, through: :source_source_role, source: :person


end
