#
# The identifier that is globaly unique.
#
class Identifier::Global < Identifier 
  validates :namespace_id, absence: true

  # only one identifier of a global type can be created  
  validates_uniqueness_of :type, scope: [:identifier]
  after_validation :set_cached_value

  protected

  def set_cached_value
    self.cached = identifier
  end


end
