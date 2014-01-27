class Identifier < ActiveRecord::Base
  include Housekeeping::Users

  belongs_to :identified_object, polymorphic: :true
  validates_presence_of :identifier, :type, :identified_object_id, :identified_object_type

  before_validation :validate_format_of_identifier

  protected

  def validate_format_of_identifier; end
end
