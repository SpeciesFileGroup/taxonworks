# A Repository is a physical location that stores collection objects.
#
# In TaxonWorks, repositories are presently built exclusively at http://grbio.org/.
#
# @!attribute name
#   @return [String]
#    the name of the repository
#
# @!attribute url
#   @return [String]
#    see  http://grbio.org/
#
# @!attribute acronym
#   @return [String]
#     a short form name for the repository
#
# @!attribute status
#   @return [String]
#     see   http://grbio.org/
#
# @!attribute institutional_LSID
#   @return [String]
#    sensu  http://grbio.org/
#
# @!attribute is_index_herbariorum
#   @return [Boolean]
#    see  http://grbio.org/
#
class Repository < ApplicationRecord
  include Housekeeping::Users
  include Housekeeping::Timestamps
  include Shared::Notes
  include Shared::SharedAcrossProjects
  include Shared::IsData
  include Shared::IsApplicationData

  has_many :collection_objects, inverse_of: :repository, dependent: :restrict_with_error
  validates_presence_of :name, :url, :acronym, :status

  scope :used_recently, -> { joins(:collection_objects).where(collection_objects: { created_at: 1.weeks.ago..Time.now } ) }
  scope :used_in_project, -> (project_id) { joins(:collection_objects).where( collection_objects: { project_id: project_id } ) }

  def self.select_optimized(user_id, project_id)
    h = {
      recent: Repository.used_in_project(project_id).used_recently.limit(10).distinct.to_a,
      pinboard: Repository.pinned_by(user_id).pinned_in_project(project_id).to_a
    }

    h[:quick] = (Repository.pinned_by(user_id).pinboard_inserted.pinned_in_project(project_id).to_a  + h[:recent][0..3]).uniq
    h
  end

end
