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
class Loan < ActiveRecord::Base
  include Housekeeping
  include Shared::IsData
  include Shared::DataAttributes
  include Shared::Identifiable
  include Shared::Notable
  include Shared::Taggable
  include SoftValidation
  include Shared::Depictions

  has_paper_trail

  


  has_many :loan_items

  has_many :loan_recipient_roles, class_name: 'LoanRecipient', as: :role_object
  has_many :loan_supervisor_roles, class_name: 'LoanSupervisor', as: :role_object

  has_many :loan_recipients, through: :loan_recipient_roles, source: :person
  has_many :loan_supervisors, through: :loan_supervisor_roles, source: :person


  # TODO: @mjy What *is* the right construct for 'Loan'?
  def self.find_for_autocomplete(params)
    where('recipient_email LIKE ?', "#{params[:term]}%")
  end

end
