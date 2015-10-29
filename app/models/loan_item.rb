
# A loan item is a CollectionObject, Container, or historical reference to 
# something that has been loaned.
#
# @!attribute loan_id
#   @return [Integer]
#   Id of the loan 
#
# @!attribute loan_object_type
#   @return [String]
#   Polymorphic- one of Container, CollectionObject, or Otu 
#
# @!attribute loan_object_id
#   @return [Integer]
#   Polymorphic, the id of the Container, CollectionObject or Otu
#
# @!attribute date_returned
#   @return [DateTime]
#   The date the item was returned. 
#
# @!attribute collection_object_status
#   @return [String]
#   @todo
#
# @!attribute position
#   @return [Integer]
#   Sorts the items in relation to the loan. 
#
# @!attribute project_id
#   @return [Integer]
#   the project ID
#
class LoanItem < ActiveRecord::Base
  acts_as_list scope: :loan

  include Housekeeping
  include Shared::IsData
  include Shared::DataAttributes
  include Shared::Notable
  include Shared::Taggable

  belongs_to :loan
  belongs_to :loan_item_object, polymorphic: true

  validates_presence_of :loan_item_object_id, :loan_item_object_type

  validates :loan_id, presence: true
  validates_uniqueness_of :loan, scope: [:loan_item_object_type, :loan_item_object_id] 
  
  validate :total_provided_only_when_otu,
           :valid_collection_object_status
  validates_inclusion_of :loan_item_object_type, in: %w{Otu CollectionObject Container}

  COLLECTION_OBJECT_STATUSES = ['Destroyed', 'Donated', 'Loaned on', 'Lost', 'Retained', 'Returned']

  protected

  # @todo Is this a legimate method for this model?
  def total_provided_only_when_otu
    errors.add(:total, 'Total only providable when item is an otu') if total && loan_item_object_type != 'Otu'
  end

  def valid_collection_object_status
    unless self.collection_object_status.nil? || COLLECTION_OBJECT_STATUSES.include?(self.collection_object_status)
      errors.add(:collection_object_status, 'Invalid collection object status')
    end
  end

  # @todo @mjy What *is* the right construct for 'LoanItem'?
  def self.find_for_autocomplete(params)
    # where('recipient_email LIKE ?', "#{params[:term]}%")
  end

end
