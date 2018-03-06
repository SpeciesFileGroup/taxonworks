# A biological relationship defines a biological relationship type between two biological entities (e.g. specimen and specimen, otu and specimen etc.)
#
# @!attribute name
#   @return [String]
#     the name of the relationship
#
# @!attribute is_transitive
#   @return [Boolean]
#     whether the relationship is transitive, i.e. if A is_a B is_a C then if is_a is transitive A is_a C
#
# @!attribute is_reflexive
#   @return [Boolean]
#     whether the relationship is reflexive, i.e. if A is_a B and is_a is_reflexive then B is_a A
#
# @!attribute project_id
#   @return [Integer]
#   the project ID
#
class BiologicalRelationship < ApplicationRecord
  include Housekeeping
  include Shared::Tags
  include Shared::Notes
  include Shared::Citations
  include Shared::DataAttributes
  include Shared::IsData

  validates_presence_of :name
  has_many :biological_relationship_types, inverse_of: :biological_relationship
  has_many :biological_associations, inverse_of: :biological_relationship
  has_many :biological_properties, through: :biological_relationship_types
 
  # TODO: move to /lib/queries
  def self.find_for_autocomplete(params)
    t = params[:term]
    t2 = t + '%'
    t3 = '%' + t2
    BiologicalRelationship.where('(name ILIKE ?) OR (name ILIKE ?) OR (name ILIKE ?)', t,t2,t3).where(project_id: params[:project_id])
  end

  # @return [Scope]
  #    the max 10 most recently used biological relationships 
  def self.used_recently
    t = BiologicalAssociation.arel_table
    k = BiologicalRelationship.arel_table 

    # i is a select manager
    i = t.project(t['biological_relationship_id'], t['created_at']).from(t)
      .where(t['created_at'].gt( 1.weeks.ago ))
      .order(t['created_at'])

    # z is a table alias 
    z = i.as('recent_t')

    BiologicalRelationship.joins(
      Arel::Nodes::InnerJoin.new(z, Arel::Nodes::On.new(z['biological_relationship_id'].eq(k['id'])))
    ).distinct.limit(10)
  end

  # @params target [String] one of `Citation` or `Content`
  # @return [Hash] topics optimized for user selection
  def self.select_optimized(user_id, project_id)
    h = {
      recent: BiologicalRelationship.where(project_id: project_id).used_recently.limit(10).distinct.to_a,
      pinboard:  BiologicalRelationship.pinned_by(user_id).where(project_id: project_id).to_a
    }

    h[:quick] = (BiologicalRelationship.pinned_by(user_id).pinboard_inserted.where(project_id: project_id).to_a  + h[:recent][0..3]).uniq
    h
  end
end
