# A ProjectOrganization links Organizations to a Project, for example the
# institutions that curate, host, or fund the data in that Project.
#
# @!attribute project_id
#   @return [Integer]
#     the project
#
# @!attribute organization_id
#   @return [Integer]
#     the organization
#
class ProjectOrganization < ApplicationRecord
  include Housekeeping
  include Shared::IsData

  belongs_to :organization, inverse_of: :project_organizations

  validates :organization, presence: true

  validates_uniqueness_of :organization_id, scope: [:project_id]

  # @return [Scope]
  #   the Depictions of the Organization in this project
  def depictions
    Depiction.where(
      depiction_object: organization,
      project_id:
    )
  end

end
