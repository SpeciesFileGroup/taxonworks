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
  include Shared::IsApplicationData
  include Shared::AlternateValues
  include Shared::DataAttributes
  include Shared::Identifiers
  include Shared::Notes
  include Shared::Tags
  include Shared::Confidences
  include Shared::IsData

  ALTERNATE_VALUES_FOR = [:name, :acronym]

  has_many :collection_objects, inverse_of: :repository, dependent: :restrict_with_error
  validates_presence_of :name, :acronym

  scope :used_in_project, -> (project_id) { joins(:collection_objects).where( collection_objects: { project_id: project_id } ) }

  def self.used_recently(user_id, project_id)
    t = CollectionObject.arel_table
    p = Repository.arel_table

    # i is a select manager
    i = t.project(t['repository_id'], t['created_at']).from(t)
            .where(t['created_at'].gt(1.weeks.ago))
            .where(t['created_by_id'].eq(user_id))
            .where(t['project_id'].eq(project_id))
            .order(t['created_at'].desc)

    # z is a table alias
    z = i.as('recent_t')

    Repository.joins(
        Arel::Nodes::InnerJoin.new(z, Arel::Nodes::On.new(z['repository_id'].eq(p['id'])))
    ).pluck(:id).uniq
  end


  def self.select_optimized(user_id, project_id)
    r = used_recently(user_id, project_id)
    h = {
      recent: (Repository.where('"repositories"."id" IN (?)', r.first(10) ).order(:name).to_a +
               Repository.where(created_by_id: user_id, created_at: 3.hours.ago..Time.now).limit(5).to_a).uniq,
    pinboard: Repository.pinned_by(user_id).pinned_in_project(project_id).to_a
    }

    h[:quick] = (Repository.pinned_by(user_id).pinboard_inserted.pinned_in_project(project_id).to_a +
        Repository.where('"repositories"."id" IN (?)', r.first(4) ).order(:name).to_a).uniq
    h
  end

end
