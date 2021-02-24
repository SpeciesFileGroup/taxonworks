# A ProjectSource links sources to projects.
#
# @!attribute project_id
#   @return [Integer]
#   the project
#
# @!attribute source_id
#   @return [Integer]
#     the source
#
class ProjectSource < ApplicationRecord
  include Housekeeping
  include Shared::IsData

  belongs_to :project, inverse_of: :project_sources
  belongs_to :source, inverse_of: :project_sources

  # source presence validation is handled in PG, as per accepts_nested_attributes constraints
  #
  validates_uniqueness_of :source_id, scope: [:project_id]
  before_destroy :check_for_use

  protected

  def check_for_use
    if source.citations.where(citations: {project: project_id}).any?
      errors.add(:base, 'Source can not be removed, it is used in this project')
      throw(:abort)
    end
  end

end
