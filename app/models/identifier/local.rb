class Identifier::Local < Identifier 
  belongs_to :namespace
  validates  :namespace, presence: true

  # identifiers of a certain type (subclass) are unique across namespaces within a project
  validates_uniqueness_of :identifier, scope: [:namespace_id, :project_id, :type]

  # Exact match on identifier + namespace
  def with_namespaced_identifier(namespace_name, identifier)
    includes(:identifiers).where(identifiers: {namespace: {name: namespace_name}}, identifier: identifier).references(:identifiers)
  end

  protected

  def set_cached_value
    if errors.empty?
      self.cached = namespace.name + " " + identifier.to_s
    end
  end

end
