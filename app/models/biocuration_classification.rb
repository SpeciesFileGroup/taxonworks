# A BiocurationClassification classifies a CollectionObject within
# a collection into some biologically-related category.  See BiocurationClass.
#
# @!attribute biocuration_class_id
#   @return [Integer]
#   the biocuration class ID
#
# @!attribute biocuration_classification_object_id
#   @return [Integer]
#   id of the object the classification is for
#
# @!attribute biocuration_classification_object_type
#   @return [String]
#      baseclass model name the classficiation is for
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

  acts_as_list scope: [:biocuration_classification_object_id, :biocuration_classification_object_type, :project_id]

  belongs_to :biocuration_class, inverse_of: :biocuration_classifications
  belongs_to :biocuration_classification_object, polymorphic: true, inverse_of: :biocuration_classifications

  validates_presence_of :biocuration_class, :biocuration_classification_object
  validates_uniqueness_of :biocuration_class, scope: [:biocuration_classification_object]

  # Janky, but here for now
  after_save :update_dwc_occurrence
  after_destroy :revert_dwc_occurrence

  protected

  def update_dwc_occurrence
    if biocuration_class.uri == DWC_FOSSIL_URI
      biocuration_classification_object.dwc_occurrence&.update_attribute(:basisOfRecord, 'FossilSpecimen')
    end
  end

  def revert_dwc_occurrence
    if biocuration_class.uri == DWC_FOSSIL_URI
      biocuration_classification_object.dwc_occurrence&.update_attribute(:basisOfRecord, 'PreservedSpecimen')
    end
  end

end
