class BiologicalAssociation < ActiveRecord::Base
  belongs_to :biological_relationship

  # TODO Must rename object
  validates_presence_of :biological_association_object_id, :object_type, :biological_association_subject_id, :subject_type
end
