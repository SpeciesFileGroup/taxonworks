# A Namespace is used to scope identifiers.  All identifiers (strings) within a namespace
# must be unique.  This is the only constraint.
#
# In TW Identifiers + namespaces are used for differentiating/disambiguating one datum from another. 
#
#
# Namespaces are minted in TW on a first come first serve basis.  Their short and
# long names must be unique across instances.  When conflicts arrise new values must be minted for 
# record keeping purposes.  In this case a verbatim_short_name can be provided, and this 
# value will be presented for reporting/searching purposes.  This is a strong restriction
# that is intended to encourage users to think before they mint namespaces.
#
# In TW Namespaces DO NOT  imply ownership! If an identifer has a namespace
# that includes reference to some collection, it does not mean that that collection 'owns' the identified object. 
#
# Namespaces in TW are *not* limited to things like collection repository codens.
#
# @!attribute institution 
#   @return [String]
#   The institution (loosely, could be a person) responsible for minting this namespace.  Roughly, where to look for more information.
#   This is NOT 1:1 with http://rs.tdwg.org/dwc/terms/ownerInstitutionCode, which implies ownership.  It is narrower in that
#   it means the institution "owns", or minted the string, that's all.
#
# @!attribute name 
#   @return [String]
#   The full name of the namespace. For example 'Illinois Natural History Collection Insect Collection'.
#   This is similar to http://rs.tdwg.org/dwc/terms/institutionCode, but not identical, in that no ownership is not explicitly implied.
#
# @!attribute short_name 
#   @return [String]
#   A short, realized version of the name.  For example "INHIC".
#   This may be embedded in http://rs.tdwg.org/dwc/terms/institutionCode.  
#   We presently do not differentiate a http://rs.tdwg.org/dwc/terms/collectionCode in 
#   identifiers, that data may(?) fall into Repositories. 
#
# @!attribute verbatim_short_name 
#   @return [String]
#   TW enforces uniqueness of short names.  When a short name exists for historical reasons but it has already
#   been included in TW then a new short name must be minted, and a verbatim_short_name used to indicate the 
#   physically/and or historically recorded value.
#
#
class Namespace < ActiveRecord::Base
  include Housekeeping::Users
  include Shared::IsData 
  include Shared::SharedAcrossProjects

  validates_presence_of :name, :short_name
  validates_uniqueness_of :name, :short_name

  has_many :identifiers, dependent: :restrict_with_error

  def self.find_for_autocomplete(params)
    match = "#{params[:term]}%"
    where('name LIKE ? OR short_name LIKE ? OR verbatim_short_name LIKE ?', match, match, match)
  end

end
