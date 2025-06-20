# A biological associations graph is a collection of BiologicalAssociations.  For example, a citable foodweb.
#
# @!attribute project_id
#   @return [Integer]
#   the project ID
#
# @!attribute name
#   @return [String]
#     the name of the graph
#
# @!attribute graph
#   @return [Json]
#      a layout for the graph
#
class BiologicalAssociationsGraph < ApplicationRecord
  include Housekeeping
  include Shared::Citations
  include Shared::Notes
  include Shared::Tags
  include Shared::Identifiers
  include Shared::AssertedDistributions
  include Shared::IsData

  has_many :biological_associations_biological_associations_graphs, inverse_of: :biological_associations_graph, dependent: :delete_all
  has_many :biological_associations, through: :biological_associations_biological_associations_graphs

  accepts_nested_attributes_for  :biological_associations_biological_associations_graphs, allow_destroy: true

  # @return [Scope]
  #    the max 10 most recently used
  def self.used_recently(user_id, project_id, used_on)
    t = case used_on
        when 'AssertedDistribution'
          AssertedDistribution.arel_table
        else
          return BiologicalAssociationsGraph.none
        end

    # i is a select manager
    i = case used_on
        when 'AssertedDistribution'
          t.project(t['asserted_distribution_object_id'], t['updated_at']).from(t)
            .where(
              t['updated_at'].gt(1.week.ago).and(
                t['asserted_distribution_object_type'].eq('BiologicalAssociationsGraph')
              )
            )
            .where(t['updated_by_id'].eq(user_id))
            .where(t['project_id'].eq(project_id))
            .order(t['updated_at'].desc)
        end

    z = i.as('recent_t')
    p = BiologicalAssociationsGraph.arel_table

    case used_on
    when 'AssertedDistribution'
      BiologicalAssociationsGraph.joins(
        Arel::Nodes::InnerJoin.new(z, Arel::Nodes::On.new(z['asserted_distribution_object_id'].eq(p['id'])))
      ).pluck(:id).uniq
    end
  end

  def self.select_optimized(user_id, project_id, klass)
    r = used_recently(user_id, project_id, klass)
    h = {
      quick: [],
      pinboard: BiologicalAssociationsGraph.pinned_by(user_id).where(project_id: project_id).to_a,
      recent: []
    }

    if r.empty?
      h[:quick] = BiologicalAssociationsGraph.pinned_by(user_id).pinboard_inserted.where(project_id: project_id).to_a
    else
      h[:recent] = BiologicalAssociationsGraph.where('"biological_associations_graphs"."id" IN (?)', r.first(10) ).order(updated_at: :desc).to_a
      h[:quick] = (BiologicalAssociationsGraph.pinned_by(user_id).pinboard_inserted.where(project_id: project_id).to_a +
                   BiologicalAssociationsGraph.where('"biological_associations_graphs"."id" IN (?)', r.first(4) ).order(updated_at: :desc).to_a).uniq
    end

    h
  end
end
