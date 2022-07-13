# A BiocurationClassification classifies a CollectionObject within
# a collection into some biologically-related category.  See BiocurationClass.
#
# @!attribute biocuration_class_id
#   @return [Integer]
#   the biocuration class ID
#
# @!attribute biological_collection_object_id
#   @return [Integer]
#   the biological collection object ID
#
# @!attribute position
#   @return [Integer]
#     used with acts_as_list
#
# @!attribute project_id
#   @return [Integer]
#   the project ID
#
class BiocurationClassification < ApplicationRecord
  include Housekeeping
  include Shared::IsData

  acts_as_list scope: [:biological_collection_object_id, :project_id]

  belongs_to :biocuration_class, inverse_of: :biocuration_classifications
  belongs_to :biological_collection_object, class_name: '::CollectionObject::BiologicalCollectionObject', inverse_of: :biocuration_classifications

  validates_presence_of :biocuration_class, :biological_collection_object
  validates_uniqueness_of :biocuration_class, scope: [:biological_collection_object]

  # Janky, but here for now
  after_save :update_dwc_occurrence
  after_destroy :revert_dwc_occurrence

  protected

  def update_dwc_occurrence
    if biocuration_class.uri == DWC_FOSSIL_URI
      biological_collection_object.dwc_occurrence&.update_attribute(:basisOfRecord, 'FossilSpecimen')
    end
  end

  def revert_dwc_occurrence
    if biocuration_class.uri == DWC_FOSSIL_URI
      biological_collection_object.dwc_occurrence&.update_attribute(:basisOfRecord, 'PreservedSpecimen')
    end
  end

end
