class BiologicalRelationship < ActiveRecord::Base

  include Housekeeping

  validates_presence_of :name
  has_many :biological_relationship_types
# has_many :subject_types, class_name: :biological_relationship_subject_type
# has_many :object_types, class_name: :biological_relationship_object_types
  has_many :biological_associations

end
