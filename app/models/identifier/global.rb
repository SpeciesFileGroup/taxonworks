#
# The identifier that is globaly unique.
#
class Identifier::Global < Identifier 
  validates :namespace_id, absence: true

  # only one identifier of a global type can be created  
  validates_uniqueness_of :type, scope: [:identifier]
end
