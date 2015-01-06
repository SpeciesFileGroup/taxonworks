# The information that can be use to differentiate concepts.
# Note this definition is presently very narrow, and that an identifier
# can in practice be used for a lot more than differentiation (i.e. 
# it can often be resolved etc.).  
#
# In TW identifiers are either global, in which case they 
# are subclassed by type, and do not include a namespace,
# or local, in which case they have a namespace.
#
#
# !! Identifiers should always be created in the context of their parents see spec/lib/identifier_spec.rb for examples  !!
#
#
## @!attribute identifier_object_id 
#   @return [Integer]
#   The id of the identified object, used in a polymorphic relationship.
#
## @!attribute identifier_object_id 
#   @return [String]
#   The type of the identified object, used in a polymorphic relationship.
#
## @!attribute identifier 
#   @return [String]
#  The string identifying the object.  Must be unique within the Namespace if provided. 
#  Same as http://rs.tdwg.org/dwc/terms/catalogNumber , but brodened in scope to be used for any data.
#
## @!attribute namespace_id 
#   @return [integer]
#   The Namespace for this identifier.
#
## @!attribute type 
#   @return [String]
#   The Rails STI subclass of this identifier.   

## @!attribute cached
#   @return [Text]
#   The full identifier, for display, i.e. namespace + identifier (local), or identifier (global).
#   
class Identifier < ActiveRecord::Base
  # TODO: @mjy resolve this to not require project id 
  include Housekeeping
  include Shared::IsData 

  before_save :set_cached_value

  # must come before SHORT_NAMES for weird inheritance issue
  belongs_to :identifier_object, polymorphic: :true

  # TODO: this likely has to be refactored/considered
  # !! If there are inheritance issues with validation the position
  # !! of this constant is likely the problem
  SHORT_NAMES = {
    doi:   Identifier::Global::Doi,
    isbn:  Identifier::Global::Isbn,
    issn:  Identifier::Global::Issn,
    lccn:  Identifier::Global::Lccn,
    orcid: Identifier::Global::Orcid,
    uri:   Identifier::Global::Uri,
    uuid:  Identifier::Global::Uuid,
    catalog_number: Identifier::Local::CatalogNumber,
    trip_code: Identifier::Local::TripCode,
    import: Identifier::Local::Import,
    otu_utility: Identifier::Local::OtuUtility,
    accession_code: Identifier::Local::AccessionCode,
    unknown: Identifier::Unknown
  }

  # Please DO NOT include the following: 
  #   validates :identifier_object, presence: true 
  #   validates_presence_of :identifier_object_type, :identifier_object_id
  validates_presence_of :type, :identifier

  # TODO: test  - pendings are in the identifier_spec
  scope :of_type, -> (type) { where(type: Identifier::SHORT_NAMES[type].to_s) }

  def self.find_for_autocomplete(params)
    where('identifier LIKE ?', "#{params[:term]}%")
  end

  protected

  def set_cached_value
  end
  
end
