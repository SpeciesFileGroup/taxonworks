# Loan description...
# @todo
#
# @!attribute date_requested
#   @return [DateTime]
#   @todo
#
# @!attribute request_method
#   @return [String]
#   @todo
#
# @!attribute date_sent
#   @return [DateTime]
#   @todo
#
# @!attribute date_received
#   @return [DateTime]
#   @todo
#
# @!attribute date_return_expected
#   @return [DateTime]
#   @todo
#
# @!attribute recipient_person_id
#   @return [Integer]
#   @todo
#
# @!attribute recipient_address
#   @return [String]
#   @todo
#
# @!attribute recipient_email
#   @return [String]
#   @todo
#
# @!attribute recipient_phone
#   @return [String]
#   @todo
#
# @!attribute recipient_country
#   @return [Integer]
#   @todo This column should probably be renamed to recipient_country_id since it is an integer...
#
# @!attribute supervisor_email
#   @return [String]
#   @todo
#
# @!attribute supervisor_phone
#   @return [String]
#   @todo
#
# @!attribute date_closed
#   @return [DateTime]
#   @todo
#
# @!attribute project_id
#   @return [Integer]
#   the project ID
#
# @!attribute recipient_honorarium
#   @return [String]
#   @todo
#
# @!attribute supervisor_person_id
#   @return [Integer]
#   @todo
#
class Loan < ActiveRecord::Base
  include Housekeeping
  include Shared::IsData

  has_paper_trail

  belongs_to :recipient_person, foreign_key: :recipient_person_id, class_name: 'Person'
  belongs_to :supervisor_person, foreign_key: :supervisor_person_id, class_name: 'Person'

  # TODO: @mjy What *is* the right construct for 'Loan'?
  def self.find_for_autocomplete(params)
    where('recipient_email LIKE ?', "#{params[:term]}%")
  end

end
