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
  include Shared::HasRoles

  has_paper_trail :on => [:update] 

  has_many :loan_items, dependent: :restrict_with_error

  has_many :loan_recipient_roles, class_name: 'LoanRecipient', as: :role_object
  has_many :loan_supervisor_roles, class_name: 'LoanSupervisor', as: :role_object

  has_many :loan_recipients, through: :loan_recipient_roles, source: :person
  has_many :loan_supervisors, through: :loan_supervisor_roles, source: :person

  validates :supervisor_email, format: {with: User::VALID_EMAIL_REGEX}, if: '!supervisor_email.blank?'
  validates :recipient_email, format: {with: User::VALID_EMAIL_REGEX}, if: '!recipient_email.blank?'

  validates :lender_address, presence: true

  validate :recieved_after_sent
  validate :returned_after_recieved
  validate :return_expected_after_sent

  accepts_nested_attributes_for :loan_items, allow_destroy: true, reject_if: :reject_loan_items
  accepts_nested_attributes_for :loan_supervisors, :loan_supervisor_roles, allow_destroy: true
  accepts_nested_attributes_for :loan_recipients, :loan_recipient_roles, allow_destroy: true

  scope :overdue, -> {where('now() > loans.date_return_expected AND date_closed IS NULL', Time.now.to_date)}

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

  # @return [Scope] of CollectionObject
  def collection_objects
    list = collection_object_ids
    if list.empty?
      CollectionObject.where('false')
    else
      CollectionObject.find(list)
    end
  end

  def overdue?
    Time.now.to_date > date_return_expected && !date_closed.present?
  end

  def days_overdue
    (Time.now.to_date - date_return_expected).to_i
  end

  def days_until_due
    (date_return_expected - Time.now.to_date ).to_i
  end

  protected

  def recieved_after_sent
    errors.add(:date_received, 'must be received on or after sent') if date_received.present? && date_sent.present? && date_received < date_sent 
  end
  
  def returned_after_recieved
    errors.add(:date_closed, 'must be closed on or after received') if date_closed.present? && date_received.present? && date_closed < date_received 
  end

  def return_expected_after_sent
    errors.add(:date_return_expected, 'must be expected after sent') if date_return_expected.present? && date_sent.present? && date_return_expected < date_sent
  end
  
  # @return [Array] collection_object ids
  def collection_object_ids
    # pile1 = Loan.joins(:loan_items).where(loan_items: {loan_id: self.id})
    retval = []
    loan_items.pluck(:id).each { |item_id|
      item = LoanItem.find(item_id)
      case item.loan_item_object_type
        when /contain/i # if this item is a container
          retval.push(item.loan_item_object.all_collection_object_ids)
        when /object/i # if this item is a collection object
          retval.push(item.loan_item_object_id)
        else
          # right now (07/13/16), since there are no other models which are 'containable', do nothing
      end
    }
    retval.flatten
  end

  def reject_taxon_determinations(attributed)
    attributed['loan_item_object_type'].blank?
  end

  def reject_loan_items(attributed)
    attributed['global_entity'].blank? && (attributed['loan_item_object_type'].blank? && attributed['loan_item_object_id'].blank?)
  end

end
