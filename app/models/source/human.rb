class Source::Human < Source

  has_one :role
  has_one :human_role, class_name: 'Role::SourceSource'
  has_one :source_source, class_name: 'Source::Human'
  has_one :person, class_name: 'Person'


end
