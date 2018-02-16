# An edge between two entities one of (CollectionObject, Otu), defines a biological relatinships between the two.
#
# @!attribute biological_relationship_id
#   @return [Integer]
#   the biological relationship ID
#
# @!attribute biological_association_subject_id
#   @return [Integer]
#     id of the subject of the relationship
#
# @!attribute biological_association_subject_type
#   @return [String]
#    type fo the subject (e.g. Otu)
#
# @!attribute biological_association_object_id
#   @return [Integer]
#    id of the object
#
# @!attribute biological_association_object_type
#   @return [String]
#    type of the object (e.g. CollectionObject)
#
# @!attribute project_id
#   @return [Integer]
#   the project ID
#
class BiologicalAssociation < ApplicationRecord
  include Housekeeping
  include Shared::Citations
  include SoftValidation
  include Shared::DataAttributes
  include Shared::Notes
  include Shared::Confidences
  include Shared::IsData

  belongs_to :biological_relationship, inverse_of: :biological_associations
  belongs_to :biological_association_subject, polymorphic: true
  belongs_to :biological_association_object, polymorphic: true
  has_many :biological_associations_biological_associations_graphs, inverse_of: :biological_association

  validates :biological_relationship, presence: true
  validates :biological_association_subject, presence: true
  validates :biological_association_object, presence: true

  validates_uniqueness_of :biological_association_subject_id, scope: [:biological_association_subject_type, :biological_association_object_id, :biological_association_object_type, :biological_relationship_id]

  attr_accessor :subject_global_id

  attr_accessor :object_global_id

  def subject_global_id=(value)
    o = GlobalID::Locator.locate(value)
    write_attribute(:biological_association_subject_id, o.id)
    write_attribute(:biological_association_subject_type, o.metamorphosize.class.name)
  end

  def object_global_id=(value)
    o = GlobalID::Locator.locate(value)
    write_attribute(:biological_association_object_id, o.id)
    write_attribute(:biological_association_object_type, o.metamorphosize.class.name)
  end

  def self.find_for_autocomplete(params)
    Queries::BiologicalAssociationAutocompleteQuery.new(params[:term]).all.where(project_id: params[:project_id])
  end

end
