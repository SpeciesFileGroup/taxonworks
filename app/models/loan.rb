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
# @!attribute recipient_honorific
#   @return [String]
#     as in Prof. Mrs. Dr. M. Mr. etc.
#
# TODO: Turn into a proper subclass when https://github.com/SpeciesFileGroup/taxonworks/issues/2120 implemented.
# @!attribute is_gift
#   @return [Boolean, nil]
#     when true then no return is expected
class Loan < ApplicationRecord
  include Housekeeping
  include Shared::DataAttributes
  include Shared::Identifiers
  include Shared::Notes
  include Shared::Tags
  include SoftValidation
  include Shared::Depictions
  include Shared::Documentation
  include Shared::HasPapertrail
  include Shared::IsData

  ignore_whitespace_on(:lender_address, :recipient_address)

  CLONED_ATTRIBUTES = [
    :lender_address,
    :recipient_address,
    :recipient_email,
    :recipient_phone,
    :recipient_country,
    :supervisor_email,
    :supervisor_phone,
    :recipient_honorific,
  ]

  # A Loan#id, when present values
  # from that record are copied
  # from the referenced loan, when
  # not otherwised populated
  attr_accessor :clone_from

  after_initialize :clone_attributes, if: Proc.new{|l| l.clone_from.present? && l.new_record? }

  has_many :loan_items, dependent: :restrict_with_error, inverse_of: :loan

  has_many :loan_recipient_roles, class_name: 'LoanRecipient', as: :role_object
  has_many :loan_supervisor_roles, class_name: 'LoanSupervisor', as: :role_object

  has_many :loan_recipients, through: :loan_recipient_roles, source: :person
  has_many :loan_supervisors, through: :loan_supervisor_roles, source: :person

  # This is not defined in HasRoles
  has_many :people, through: :roles

  not_super = lambda {!supervisor_email.blank?}
  validates :supervisor_email, format: {with: User::VALID_EMAIL_REGEX}, if: not_super
  validates :recipient_email, format: {with: User::VALID_EMAIL_REGEX}, if: not_super

  validates :lender_address, presence: true

  validate :requested_after_sent
  validate :requested_after_received
  validate :requested_after_expected
  validate :requested_after_closed
  validate :sent_after_received
  validate :sent_after_expected
  validate :sent_after_closed
  validate :received_after_closed
  validate :received_after_expected

  validate :gift_or_date_expected_required

  soft_validate(
    :sv_missing_documentation,
    set: :missing_documentation,
    name: 'Missing documentation',
    description: 'No documnets')

  accepts_nested_attributes_for :loan_items, allow_destroy: true, reject_if: :reject_loan_items
  accepts_nested_attributes_for :loan_supervisors, :loan_supervisor_roles, allow_destroy: true
  accepts_nested_attributes_for :loan_recipients, :loan_recipient_roles, allow_destroy: true

  scope :overdue, -> {where('now() > loans.date_return_expected AND date_closed IS NULL', Time.now.to_date)}

  # @return [Scope] of CollectionObject
  def collection_objects
    list = collection_object_ids
    if list.empty?
      CollectionObject.where('false')
    else
      CollectionObject.find(list)
    end
  end

  # @return [Boolean, nil]
  def overdue?
    if date_return_expected.present?
      Time.now.to_date > date_return_expected && !date_closed.present?
    else
      nil
    end
  end

  # @return [Integer, nil]
  def days_overdue
    if date_return_expected.present?
      (Time.now.to_date - date_return_expected).to_i
    else
      nil
    end
  end

  # @return [Integer, false]
  def days_until_due
    date_return_expected && (date_return_expected - Time.now.to_date ).to_i
  end

  # @return [Array] collection_object ids
  def collection_object_ids
    retval = []
    loan_items.each do |li|
      case li.loan_item_object_type
      when 'Container'
        retval += li.loan_item_object.all_collection_object_ids
      when 'CollectionObject'
        retval.push(li.loan_item_object_id)
      when 'Otu'
        retval += li.loan_item_object.collection_objects.pluck(:id)
      else
      end
    end
    retval
  end

  # @return [Scope]
  #   the max 10 most recently used loans
  def self.used_recently(project_id)
    t = LoanItem.arel_table
    k = Loan.arel_table

    # i is a select manager
    i = t.project(t['loan_id'], t['created_at']).from(t)
      .where(t['created_at'].gt( 3.weeks.ago ))
      .where(t['project_id'].eq(project_id))
      .order(t['created_at'].desc)

    # z is a table alias
    z = i.as('recent_t')

    Loan.joins(
      Arel::Nodes::InnerJoin.new(z, Arel::Nodes::On.new(z['loan_id'].eq(k['id'])))
    ).pluck(:loan_id).uniq
  end

  def self.select_optimized(user_id, project_id)
    r = used_recently(project_id)
    h = {
        quick: [],
        pinboard: Loan.pinned_by(user_id).where(project_id: project_id).to_a,
        recent: []
    }

    if r.empty?
      h[:quick] = Loan.pinned_by(user_id).pinboard_inserted.where(project_id: project_id).to_a
    else
      h[:recent] = Loan.where(id: r.first(10)).to_a
      h[:quick] = (Loan.pinned_by(user_id).pinboard_inserted.where(project_id: project_id).to_a +
          Loan.where(id: r.first(4)).to_a).uniq
    end
    h
  end

  def contains_types?
    collection_objects.each do |c|
      return true if c.type_materials.any?
    end
    false
  end

  protected

  def clone_attributes
    l = Loan.find(clone_from)
    CLONED_ATTRIBUTES.each do |a|
      write_attribute(a, l.send(a))
    end

    l.loan_recipients.each do |p|
      roles.build(type: 'LoanRecipient', person: p)
    end

    l.loan_supervisors.each do |p|
      roles.build(type: 'LoanSupervisor', person: p)
    end
  end

  def gift_or_date_expected_required
    errors.add(:date_return_expected, ' or gift status is required') if is_gift.nil? && date_return_expected.nil?
  end

  def requested_after_sent
    errors.add(:date_requested, 'must be sent after requested') if date_requested.present? && date_sent.present? && date_sent < date_requested
  end

  def requested_after_received
    errors.add(:date_requested, 'must be received after requested') if date_requested.present? && date_received.present? && date_received < date_requested
  end

  def requested_after_expected
    errors.add(:date_requested, 'must be expected after requested') if date_requested.present? && date_return_expected.present? && date_return_expected < date_requested
  end

  def requested_after_closed
    errors.add(:date_requested, 'must be closed after requested') if date_requested.present? && date_closed.present? && date_closed < date_requested
  end

  def sent_after_received
    errors.add(:date_sent, 'must be received after sent') if date_sent.present? && date_received.present? && date_received < date_sent
  end

  def sent_after_expected
    errors.add(:date_sent, 'must be expected after sent') if date_sent.present? && date_return_expected.present? && date_return_expected < date_sent
  end

  def sent_after_closed
    errors.add(:date_sent, 'must be closed after sent') if date_sent.present? && date_closed.present? && date_closed < date_sent
  end

  def received_after_closed
    errors.add(:date_received, 'must be closed after received') if date_closed.present? && date_received.present? && date_closed < date_received
  end

  def received_after_expected
    errors.add(:date_received, 'must be expected after received') if date_return_expected.present? && date_received.present? && date_return_expected < date_received
  end

  def reject_loan_items(attributed)
    attributed['global_entity'].blank? && (attributed['loan_item_object_type'].blank? && attributed['loan_item_object_id'].blank?)
  end

  def sv_missing_documentation
    soft_validations.add(:base, 'No documents') unless self.documents.any?
  end
end
