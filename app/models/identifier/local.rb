class Identifier::Local < Identifier 
  belongs_to :namespace
  validates  :namespace, presence: true

  after_validation :set_cached_value

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
