# A Loan is the metadata that wraps/describes an exchange of specimens.
#
# @!attribute date_requested
#   @return [DateTime]
#     date request was recieved by lender
#
# @!attribute request_method
#   @return [String]
#     brief not as to how the request was made, not a controlled vocabulary 
#
# @!attribute date_sent
#   @return [DateTime]
#     date loan was delivered to post 
#
# @!attribute date_received
#   @return [DateTime]
#     date loan was recievied by recipient 
#
# @!attribute date_return_expected
#   @return [DateTime]
#      date expected 
#
# @!attribute recipient_address
#   @return [String]
#     address loan sent to 
#
# @!attribute recipient_email
#   @return [String]
#     email address of recipient
#
# @!attribute recipient_phone
#   @return [String]
#     phone number of recipient 
#
# @!attribute recipient_country
#   @return [String]
#
# @!attribute supervisor_email
#   @return [String]oe
#     email of utlimately responsible party if recient can not be 
#
# @!attribute supervisor_phone
#   @return [String]
#     phone # of utlimately responsible party if recient can not be 
#
# @!attribute date_closed
#   @return [DateTime]
#     date at which loan has been fully resolved and requires no additional attention 
#
# @!attribute project_id
#   @return [Integer]
#   the project ID
#
# @!attribute recipient_honorarium
#   @return [String]
#     as in Prof. Mrs. Dr. M. Mr. etc.
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

  validates :lender_address, presence: true

  accepts_nested_attributes_for :loan_items, allow_destroy: true, reject_if: :reject_loan_items
  accepts_nested_attributes_for :loan_supervisors, :loan_supervisor_roles, allow_destroy: true
  accepts_nested_attributes_for :loan_recipients, :loan_recipient_roles, allow_destroy: true

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

  protected

  def reject_taxon_determinations(attributed)
    attributed['loan_item_object_type'].blank?
  end

  def reject_loan_items(attributed)
    attributed['global_entity'].blank? && ( attributed['loan_item_object_type'].blank? && attributed['loan_item_object_id'].blank?)
  end

end
