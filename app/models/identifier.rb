class Identifier < ActiveRecord::Base
  include Housekeeping::Users

  SHORT_NAMES = {
    issn: Identifier::Guid::Issn,
    isbn: Identifier::Guid::Isbn
  }

  belongs_to :identified_object, polymorphic: :true
  validates_presence_of :identifier, :type, :identified_object_id, :identified_object_type

  before_validation :validate_format_of_identifier

  # TODO: test
  scope :of_type, -> (type) {where(type: Identifier::SHORT_NAMES[type].to_s)} 

  protected

  def validate_format_of_identifier; end
end
