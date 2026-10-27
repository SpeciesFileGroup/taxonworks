# A PreparationType describes how a collection object was prepared for preservation in a collection.  At present we're building a shared controlled vocabulary that
# we may ultimately try and turn into an ontology.
#
# @!attribute name
#   @return [String]
#     the name of the preparation
#
# @!attribute definition
#   @return [String]
#     a definition describing the preparation
#
class PreparationType < ApplicationRecord
  include Housekeeping::Users
  include Housekeeping::Timestamps
  include Shared::Tags
  include Shared::SharedAcrossProjects
  include Shared::HasPapertrail
  include Shared::IsData

  has_many :collection_objects, dependent: :restrict_with_error, inverse_of: :preparation_type
  has_many :anatomical_parts, inverse_of: :preparation_type, dependent: :restrict_with_error

  validates_presence_of :name, :definition

  validates_uniqueness_of :name
  validates_uniqueness_of :definition

  # The classes that assert a preparation_type_id, and against which recent
  # use is measured for the smart selector.
  USED_ON_KLASSES = %w{CollectionObject AnatomicalPart}.freeze

  # @param used_on [String] one of USED_ON_KLASSES
  # @return [Array]
  #   the ids of the preparation types most recently used by the user in the project
  def self.used_recently(user_id, project_id, used_on)
    return [] unless USED_ON_KLASSES.include?(used_on)

    t = used_on.constantize.arel_table
    p = PreparationType.arel_table

    # i is a select manager
    i = t.project(t['preparation_type_id'], t['updated_at']).from(t)
      .where(t['updated_at'].gt(4.weeks.ago))
      .where(t['updated_by_id'].eq(user_id))
      .where(t['project_id'].eq(project_id))
      .order(t['updated_at'].desc)

    # z is a table alias
    z = i.as('recent_t')

    PreparationType.joins(
      Arel::Nodes::InnerJoin.new(z, Arel::Nodes::On.new(z['preparation_type_id'].eq(p['id'])))
    ).pluck(:id).uniq
  end

  # @return [Hash]
  #   preparation types optimized for user selection
  def self.select_optimized(user_id, project_id, target)
    r = used_recently(user_id, project_id, target)

    h = {
      quick: [],
      pinboard: PreparationType.pinned_by(user_id).pinned_in_project(project_id).pinboard_ordered.to_a,
      recent: []
    }

    if r.empty?
      h[:quick] = PreparationType.pinned_by(user_id).pinboard_inserted.pinned_in_project(project_id).to_a
    else
      h[:recent] = PreparationType.where(id: r.first(10)).order(:name).to_a
      h[:quick] = (
        PreparationType.pinned_by(user_id).pinboard_inserted.pinned_in_project(project_id).to_a +
        PreparationType.where(id: r.first(4)).order(:name).to_a
      ).uniq
    end

    h
  end

end
