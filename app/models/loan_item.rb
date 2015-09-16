# Loan description...
# @todo
#
# @!attribute loan_id
#   @return [Integer]
#   @todo
#
# @!attribute collection_object_id
#   @return [Integer]
#   @todo
#
# @!attribute date_returned
#   @return [DateTime]
#   @todo
#
# @!attribute collection_object_status
#   @return [String]
#   @todo
#
# @!attribute position
#   @return [Integer]
#   @todo
#
# @!attribute project_id
#   @return [Integer]
#   the project ID
#
# @!attribute container_id
#   @return [Integer]
#   @todo
#
class LoanItem < ActiveRecord::Base
  acts_as_list scope: :loan

  include Housekeeping
  include Shared::IsData
  include Shared::DataAttributes
  include Shared::Notable
  include Shared::Taggable

  belongs_to :loan
  belongs_to :collection_object

  validates :loan_id, presence: true
  validates_uniqueness_of :collection_object_id, scope: [:loan_id, :container_id]
  validate :only_one_present

  def only_one_present
    if self.collection_object_id.nil? && self.container_id.nil?
      errors.add(:collection_object_id, 'Either collection object or container should be selected')
      errors.add(:container_id, 'Either collection object or container should be selected')
    elsif !self.collection_object_id.nil? && !self.container_id.nil?
      errors.add(:collection_object_id, 'Only one collection object or container could be selected')
      errors.add(:container_id, 'Only one collection object or container could be selected')
    end
  end

end
