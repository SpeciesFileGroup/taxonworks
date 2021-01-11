# The identifier that is generated for local use, i.e. no signficant effort (countering example DOIs) was 
# made to ensure global uniqueness.  While most identifiers are intended to be unique globally, few
# consider mechanisms for ensuring this.
#
# Local identifiers of the same type may be stacked on a single record without defining the relation
# between each identifier (see conceptual difference in Identfier::Global).
#
# Local identifiers require a namespace. See Namespace.  
# 
# Multiple local identfiers of the same namespace can be applied to the same object, while this is rarely useful in real life
# it does have physical-world analogs, see in particular Accession numbers on Collecting Events linked to Specimens that are in the process of 
# being accessioned.
#
#   Foo 123 (CatalogNumber) 
#   Foo 345 (CatalogNumber)
#
# You can also do this on the same object: 
#   Foo 123 (CatalogNumber)
#   Bar 123 (CatalogNumber)
#  
# In addition, identifiers of a certain type (subclass) must be unique across namespaces within a project.
#
class Identifier::Local < Identifier

  # This must exist, rather than namespace: true, because we don't have database side not null in the model.  We also don't accept nested
  # namespaces in this belongs to.
  validates :namespace_id, presence: true

  validates_uniqueness_of :identifier, scope: [:namespace_id, :project_id, :type], message: lambda { |error, attributes| "#{attributes[:value]} already taken"}

  # Exact match on identifier + namespace
  # @param [String, String]
  # @return [Scope]
  def with_namespaced_identifier(namespace_name, identifier)
    ret_val = includes(:identifiers).where(identifiers: {namespace: {name: namespace_name}}, identifier: identifier).references(:identifiers)
    if ret_val.count == 0
      ret_val = includes(:identifiers).where(identifiers: {namespace: {short_name: namespace_name}}, identifier: identifier).references(:identifiers)
    end
    ret_val
  end

  protected

  # @return string
  def delimiter
    a = namespace&.read_attribute(:delimiter)
    return '' if a == 'NONE' 
    [a, ' '].compact.first
  end

  def build_cached
    [namespace.verbatim_short_name, namespace.short_name].compact.first + delimiter + identifier.to_s
  end

  def set_cached
    update_column(:cached, build_cached)
  end

end
