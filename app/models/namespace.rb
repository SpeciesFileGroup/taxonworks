# A namespace is used to scope identifiers.
#
# In TW Identifiers/namespaces are used for disambiguating one datum from another. 
#
# A namespace + identifier equates to a 
#
# All strings (identifiers) within a namespace
# must be unique, that's all. In TW Namespaces DO NOT 
# imply ownership, i.e. if an identifer has a namespace
# that includes reference to some collection, it does
# not mean that that collecition 'owns' the identified object.
#
#
## @!attribute institution 
#   @return [String]
#   The institution (loosely, could be a person) responsible for minting this namespace.  Roughly, where to look for more information.
#   This is NOT 1:1 with http://rs.tdwg.org/dwc/terms/ownerInstitutionCode, which implies ownership.  It is narrower in that
#   it means the institution "owns", or minted the string, that's all.
#
## @!attribute name 
#   @return [String]
#   The full name of the namespace. For example 'Illinois Natural History Collection Insect Collection'.
#   This is similar to http://rs.tdwg.org/dwc/terms/institutionCode, but not identical, in that no ownership is not explicitly implied.
#
## @!attribute short_name 
#   @return [String]
#   A short, realized version of the name.  For example "INHIC" 
#   This may be embedded in http://rs.tdwg.org/dwc/terms/institutionCode.  
#   We presently do not differentiate a http://rs.tdwg.org/dwc/terms/collectionCode in 
#   identifiers, that data may(?) fall into Repositories. 
#
#
class Namespace < ActiveRecord::Base
  include Housekeeping::Users
  include Shared::IsData 
  include Shared::SharedAcrossProjects

  validates_presence_of :name, :short_name
  validates_uniqueness_of :name, :short_name

  has_many :identifiers, dependent: :restrict_with_error

  # TODO: @mjy What *is* the right construct for 'Namespace'?
  def self.find_for_autocomplete(params)
    where('name LIKE ?', "#{params[:term]}%")
  end

end
