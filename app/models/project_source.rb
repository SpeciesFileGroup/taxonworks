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

  validates :source, presence: true
  validates :project, presence: true

  validates_uniqueness_of :source_id, scope: [:project_id]
  before_destroy :check_for_use

  def self.batch_sync_to_project(params, operation, project_id = nil)
    return false if project_id.nil?

    sources = Queries::Source::Filter.new(params[:source_query])

    i = 0

    if sources.all.any? && !sources.params.empty?
      case operation.to_sym
      when :add
        sources.all.find_each do |s|
          # e.g. already in the project; skip it, keep adding the rest
          i += 1 if ProjectSource.create(source_id: s.id, project_id:).persisted?
        end
      when :remove
        ProjectSource
          .where(project_id:, source_id: sources.all.unscope(:select, :order).select(:id))
          .find_each do |ps|
            i += 1 if ps.destroy # we want callbacks here
          end
      else
        return false
      end
    end
    i
  end


  protected

  def check_for_use
    if source.citations.where(citations: {project: project_id}).any?
      errors.add(:base, 'Source can not be removed, it is used in this project')
      throw(:abort)
    end
  end

end
