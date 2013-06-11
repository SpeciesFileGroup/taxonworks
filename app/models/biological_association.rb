class BiologicalAssociation < ActiveRecord::Base
  belongs_to :biological_relationship

  validates_presence_of :object_id, :object_type, :subject_id, :subject_type
end
