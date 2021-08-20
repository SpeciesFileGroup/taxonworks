# A biological relationship defines a biological relationship type between two biological entities (e.g. specimen and specimen, otu and specimen etc.)
#
# @!attribute name
#   @return [String]
#     the name of the relationship
#
# @!attribute inverted_name
#   @return [String]
#     the name as if read in reverse (from perspective of object), for example name: `parasitoid_of` inverted_name: `host_of`. Optional.
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

  has_many :subject_biological_relationship_types, -> () {where(type: 'BiologicalRelationshipType::BiologicalRelationshipSubjectType')}, class_name: 'BiologicalRelationshipType'
  has_many :object_biological_relationship_types, -> () {where(type: 'BiologicalRelationshipType::BiologicalRelationshipObjectType')}, class_name: 'BiologicalRelationshipType'

  has_many :biological_properties, through: :biological_relationship_types
  has_many :subject_biological_properties, through: :subject_biological_relationship_types, source: :biological_property
  has_many :object_biological_properties, through: :object_biological_relationship_types, source: :biological_property

  has_many :biological_associations, inverse_of: :biological_relationship

  accepts_nested_attributes_for :biological_relationship_types, allow_destroy: true

  # @return [Scope]
  #    the max 10 most recently used biological relationships 
  def self.used_recently(user_id, project_id)
      t = BiologicalAssociation.arel_table
    k = BiologicalRelationship.arel_table 

    # i is a select manager
    i = t.project(t['biological_relationship_id'], t['created_at']).from(t)
      .where(t['created_at'].gt( 10.weeks.ago ))
      .where(t['created_by_id'].eq(user_id))
      .where(t['project_id'].eq(project_id))
      .order(t['created_at'].desc)

    # z is a table alias 
    z = i.as('recent_t')

    BiologicalRelationship.joins(
      Arel::Nodes::InnerJoin.new(z, Arel::Nodes::On.new(z['biological_relationship_id'].eq(k['id'])))
    ).pluck(:biological_relationship_id).uniq
  end

  # @params target [String] one of `Citation` or `Content`
  # @return [Hash] topics optimized for user selection
  def self.select_optimized(user_id, project_id)
    r = used_recently(user_id, project_id)

    h = {
        quick: [],
        pinboard: BiologicalRelationship.pinned_by(user_id).where(project_id: project_id).to_a,
        recent: []
    }

    if r.empty?
      h[:quick] = BiologicalRelationship.pinned_by(user_id).pinboard_inserted.where(project_id: project_id).to_a
    else
      h[:recent] = BiologicalRelationship.where('"biological_relationships"."id" IN (?)', r.first(10) ).order(:name).to_a
      h[:quick] = (BiologicalRelationship.pinned_by(user_id).pinboard_inserted.where(project_id: project_id).to_a +
          BiologicalRelationship.where('"biological_relationships"."id" IN (?)', r.first(5) ).order(:name).to_a).uniq
    end

    h
  end
end
