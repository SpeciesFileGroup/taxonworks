class Identifier < ActiveRecord::Base

  include Housekeeping::Users

  belongs_to :identifiable, polymorphic: :true
  validates_presence_of :identifier, :identifiable_id, :identifiable_type, :type

  before_validation: :validate_format_of_identifier

  protected

  def validate_format_of_identifier; end

end
