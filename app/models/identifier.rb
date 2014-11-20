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
## @!attribute identified_object_id 
#   @return [Integer]
#   The id of the identified object, used in a polymorphic relationship.
#
## @!attribute identified_object_id 
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
  include Housekeeping
  include Shared::IsData 

  # must come before SHORT_NAMES for weird inheritance issue
  belongs_to :identified_object, polymorphic: :true

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
  #   validates :identified_object, presence: true 
  #   validates_presence_of :identified_object_type, :identified_object_id
  
  validates_presence_of :type, :identifier

  # identifiers are unique across types for a class of objects
  validates_uniqueness_of :identifier, scope: [:type, :identified_object_type, :namespace_id]

  # no more of one identifier of a type per object 
  validates_uniqueness_of :type, scope: [:identified_object_id, :identified_object_type, :namespace_id, :project_id] 

  #before_validation :validate_format_of_identifier

  # TODO: test  - pendings are in the identifier_spec
  scope :of_type, -> (type) { where(type: Identifier::SHORT_NAMES[type].to_s) }

  protected

  # validations are currently defined in the subclass using active record validations.
  #def validate_format_of_identifier
  #end
  
end
