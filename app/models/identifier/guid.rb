class Identifier::Guid < Identifier 
  validates :namespace_id, absence: true
end
