class BiologicalAssociation < ActiveRecord::Base
  belongs_to :biological_relationship

  # TODO Must rename object
  validates_presence_of :object_id, :object_type, :subject_id, :subject_type
end
