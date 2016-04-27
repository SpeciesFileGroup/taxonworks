# A Loan is the metadata that wraps/describes an exchange of specimens.
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
#   @return [String]
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

  validates :supervisor_email, format: {with: User::VALID_EMAIL_REGEX}, if: '!supervisor_email.blank?'
  validates :recipient_email, format: {with: User::VALID_EMAIL_REGEX}, if: '!recipient_email.blank?'

  # TODO: @mjy What *is* the right construct for 'Loan'?
  def self.find_for_autocomplete(params)
    where('recipient_email LIKE ?', "#{params[:term]}%")
  end

  # @return [CSV]
  # Generate a CSV version of the raw Loans table for the given scope
  # Ripped from http://railscasts.com/episodes/362-exporting-csv-and-excel
  def self.generate_download(scope)
    CSV.generate do |csv|
      csv << column_names
      scope.order(id: :asc).each do |o|
        csv << o.attributes.values_at(*column_names).collect { |i|
          i.to_s.gsub(/\n/, '\n').gsub(/\t/, '\t')
        }
      end
    end
  end

end
