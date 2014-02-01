class Identifier < ActiveRecord::Base
  include Housekeeping::Users

  SHORT_NAMES = {
    doi:   Identifier::Guid::Doi,
    isbn:  Identifier::Guid::Isbn,
    issn:  Identifier::Guid::Issn,
    lccn:  Identifier::Guid::Lccn,
    orcid: Identifier::Guid::OrcidId,
    uri:   Identifier::Guid::Uri,
    uuid:  Identifier::Guid::Uuid
  }

  belongs_to :identified_object, polymorphic: :true
  validates_presence_of :identifier, :type, :identified_object_id, :identified_object_type

  #before_validation :validate_format_of_identifier

  # TODO: test  - pendings are in the identifier_spec
  scope :of_type, -> (type) { where(type: Identifier::SHORT_NAMES[type].to_s) }

  protected

  # validations are currently defined in the subclass using active record validations.
  #def validate_format_of_identifier;
  #end
end
