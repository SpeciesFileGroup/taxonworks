class ProjectSource < ActiveRecord::Base
  include Housekeeping

  belongs_to :project, inverse_of: :project_sources
  belongs_to :source, inverse_of: :project_sources

  validates :source, presence: true

  validates_uniqueness_of :source_id, scope: [:project_id]
end
