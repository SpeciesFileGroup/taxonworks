# A biocuration classification is...
#   @todo
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
#   @todo
#
# @!attribute project_id
#   @return [Integer]
#   the project ID
#
class BiocurationClassification < ActiveRecord::Base
  acts_as_list scope: [:biological_collection_object]

  include Housekeeping
  include Shared::IsData 
  
  belongs_to :biocuration_class, inverse_of: :biocuration_classifications
  belongs_to :biological_collection_object, class_name: 'CollectionObject::BiologicalCollectionObject', inverse_of: :biocuration_classifications

  validates_presence_of :biocuration_class, :biological_collection_object

end
