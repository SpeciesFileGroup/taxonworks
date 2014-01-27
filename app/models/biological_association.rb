class BiologicalAssociation < ActiveRecord::Base
  include Shared::Citable
  include Housekeeping

  belongs_to :biological_relationship, inverse_of: :biological_associations
  belongs_to :biological_association_subject, polymorphic: true
  belongs_to :biological_association_object, polymorphic: true
  has_many :biological_associations_biological_associations_graphs, inverse_of: :biological_association

  validates :biological_relationship, presence: true
  validates :biological_association_subject, presence: true
  validates :biological_association_object, presence: true

end
