class Identifier < ActiveRecord::Base
  include Housekeeping

  # must come before SHORT_NAMES for weird inheritance issue
  belongs_to :identified_object, polymorphic: :true

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

  }

  validates :identified_object, presence: true
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
  #def validate_format_of_identifier;
  #end
end
