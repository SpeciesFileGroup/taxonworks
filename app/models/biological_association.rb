class BiologicalAssociation < ActiveRecord::Base
  # include Shared::Citable
  include Housekeeping

  belongs_to :biological_relationship
  belongs_to :biological_association_subject, polymorphic: true
  belongs_to :biological_association_object, polymorphic: true

  validates :biological_relationship, presence: true
  validates :biological_association_subject, presence: true
  validates :biological_association_object, presence: true

end
