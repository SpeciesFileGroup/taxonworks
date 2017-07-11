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

  validates_uniqueness_of :source_id, scope: [:project_id]
end
