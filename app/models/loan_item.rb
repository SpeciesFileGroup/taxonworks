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

  belongs_to :loan
  belongs_to :collection_object
end
