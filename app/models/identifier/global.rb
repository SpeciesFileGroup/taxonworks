# The identifier that is globally unique.
#
# Curators of a specific project assert one canonical global identifier per type for each object, this
# identifier is identified by having .relation.nil?.  If the curators feel there are multiple global identifiers
# for a given instance they must provide an explicit relationship between the canonical identifier and the
# alternate identifiers.
#
# @!attribute relation
#   @return [String]
#   Defines the relationship between the curator asserted canonical identifier and other identifiers
#   of the same type. Must be provided for every global identifier of the same type beyond the first.
#   Relations are drawn from skos (http://www.w3.org/TR/skos-reference/#mapping)
#
class Identifier::Global < Identifier

  include SoftValidation

  validates :namespace_id, absence: true
  validates :relation, inclusion: {in: ::SKOS_RELATIONS.keys}, allow_nil: true
  validate :permit_only_one_global_without_relation_supplied_per_type

  # Identifier can only be used once, i.e. mapped to a single TW concept
  validates_uniqueness_of :identifier, scope: [:project_id]

  soft_validate(:sv_resolves?, set: :resolved)

  def is_global?
    true
  end

  protected

  def build_cached
    identifier
  end

  def permit_only_one_global_without_relation_supplied_per_type
    if identifier_object && identifier_object.identifiers.where(type: type.to_s).where.not(id: id).any?
      errors.add(:relation,
                 " an existing identifier of type #{type} exists, a relation for this identifier must be provided"
      ) if self.relation.nil?
    end
  end

  def sv_resolves?
    responded = false
    unless identifier.nil?
      responded = Utilities::Net.resolves?(identifier)
    end
    soft_validations.add(:identifier, "Identifier '#{identifier}' does not resolve.") unless responded
    responded
  end

end
