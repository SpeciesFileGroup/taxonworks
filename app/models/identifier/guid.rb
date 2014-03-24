class Identifier::Guid < Identifier 
  validates :namespace_id, absence: true
  # TODO test this
  validates_uniqueness_of :type, scope: [:identified_object_id, :identified_object_type]
end
