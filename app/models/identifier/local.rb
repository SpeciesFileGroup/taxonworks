# The identifier that is generated for local use, i.e. no signficant effort (countering example DOIs) was 
# made to ensure global uniqueness.  While most identifiers are intended to be unique globally, few
# consider mechanisms for ensuring this.
#
# Local identifiers may of the same type may be stacked on a single record without defining the relation
# between each identifier (see conceptual difference in Identfier::Global).
#
# Local identifiers require a namespace.  See Namespace.  
# 
#
#
# Only one namespaced identifier is allowed per type per object, i.e. you can't have, on a single specimen:
#   Foo 123 (CatalogNumber) 
#   Foo 345 (CatalogNumber)
#
# However you *can* have:
#   Foo 123 (CatalogNumber)
#   Bar 123 (CatalogNumber)
#  
# In addition, identifiers of a certain type (subclass) must be unique across namespaces within a project.
#
#
class Identifier::Local < Identifier
  belongs_to :namespace

  validates :namespace, presence: true
  validates_uniqueness_of :identifier, scope: [:namespace_id, :project_id, :type]
  validates_uniqueness_of :namespace, scope: [:identifier_object_type, :identifier_object_id, :type]

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

  def set_cached_value
    if errors.empty?
      self.cached = namespace.short_name + " " + identifier.to_s
    end
  end

end
