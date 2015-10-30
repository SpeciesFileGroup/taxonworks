# A biological association is...
#   @todo
#
# @!attribute biological_relationship_id
#   @return [Integer]
#   the biological relationship ID
#
# @!attribute biological_association_subject_id
#   @return [Integer]
#   @todo
#
# @!attribute biological_association_subject_type
#   @return [String]
#   @todo
#
# @!attribute biological_association_object_id
#   @return [Integer]
#   @todo
#
# @!attribute biological_association_object_type
#   @return [String]
#   @todo
#
# @!attribute project_id
#   @return [Integer]
#   the project ID
#
class BiologicalAssociation < ActiveRecord::Base
  include Housekeeping
  include Shared::Citable
  include Shared::IsData

  belongs_to :biological_relationship, inverse_of: :biological_associations
  belongs_to :biological_association_subject, polymorphic: true
  belongs_to :biological_association_object, polymorphic: true
  has_many :biological_associations_biological_associations_graphs, inverse_of: :biological_association

  validates :biological_relationship, presence: true
  validates :biological_association_subject, presence: true
  validates :biological_association_object, presence: true

  validates_uniqueness_of :biological_association_subject_id, scope: [:biological_association_subject_type, :biological_association_object_id, :biological_association_object_type, :biological_relationship_id]

  def self.find_for_autocomplete(params)
    Queries::BiologicalAssociationAutocompleteQuery.new(params[:term]).all.where(project_id: params[:project_id])
  end

end
