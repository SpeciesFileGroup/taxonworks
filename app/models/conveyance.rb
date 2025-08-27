# A depiction is the linkage between an sound and a data object.  For example
# an Sound may convey some CollectionObject or OTU.
#
# @!attribute sound_id
#   @return [Integer]
#     the id of the Sound being conveyed
#
# @!attribute conveyance_object_type
#   @return [String]
#     the type of object being conveyed
#
# @!attribute conveyance_object_id
#   @return [Integer]
#     the id of the object being conveyed
#
# @!attribute start_time
#   @return [Numeric]
#     in seconds

# @!attribute end_time
#   @return [Numeric]
#     in seconds
#
class Conveyance < ApplicationRecord
  include Housekeeping
  include Shared::Citations
  include Shared::Notes
  include Shared::Tags
  include Shared::AssertedDistributions
  include Shared::PolymorphicAnnotator
  include Shared::IsData
  polymorphic_annotates(:conveyance_object)

  GRAPH_ENTRY_POINTS = [:asserted_distributions].freeze

  acts_as_list scope: [:project_id, :conveyance_object_type, :conveyance_object_id]

  belongs_to :sound, inverse_of: :conveyances
  belongs_to :conveyance_object, polymorphic: true

  validates_presence_of :conveyance_object, :sound

  validates_uniqueness_of :sound_id, scope: [:conveyance_object_type, :conveyance_object_id]

  validate :end_time_after_start

  accepts_nested_attributes_for :sound

  # @return [Scope]
  #    the max 10 most recently used
  def self.used_recently(user_id, project_id, used_on)
    t = case used_on
        when 'AssertedDistribution'
          AssertedDistribution.arel_table
        else
          return Conveyance.none
        end

    # i is a select manager
    i = case used_on
        when 'AssertedDistribution'
          t.project(t['asserted_distribution_object_id'], t['updated_at']).from(t)
            .where(
              t['updated_at'].gt(1.week.ago).and(
                t['asserted_distribution_object_type'].eq('Conveyance')
              )
            )
            .where(t['updated_by_id'].eq(user_id))
            .where(t['project_id'].eq(project_id))
            .order(t['updated_at'].desc)
        end

    z = i.as('recent_t')
    p = Conveyance.arel_table

    case used_on
    when 'AssertedDistribution'
      Conveyance.joins(
        Arel::Nodes::InnerJoin.new(z, Arel::Nodes::On.new(z['asserted_distribution_object_id'].eq(p['id'])))
      ).pluck(:id).uniq
    end
  end

  def self.select_optimized(user_id, project_id, klass)
    r = used_recently(user_id, project_id, klass)
    h = {
      quick: [],
      pinboard: Conveyance.pinned_by(user_id).where(project_id: project_id).to_a,
      recent: []
    }

    if r.empty?
      h[:quick] = Conveyance.pinned_by(user_id).pinboard_inserted.where(project_id: project_id).to_a
    else
      h[:recent] = Conveyance.where('"conveyances"."id" IN (?)', r.first(10) ).order(updated_at: :desc).to_a
      h[:quick] = (Conveyance.pinned_by(user_id).pinboard_inserted.where(project_id: project_id).to_a +
                   Conveyance.where('"conveyances"."id" IN (?)', r.first(4) ).order(updated_at: :desc).to_a).uniq
    end

    h
  end

  protected

  def end_time_after_start
    if (start_time && end_time) && start_time > end_time
      errors.add(:end_time, 'must be after start time')
    end
  end

end

