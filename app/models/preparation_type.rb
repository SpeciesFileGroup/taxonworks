# A PreparationType describes how a collection object was prepared for preservation in a collection.  At present we're building a shared controlled vocabulary that
# we may ultimately try and turn into an ontology.
#
# @!attribute name
#   @return [String]
#     the name of the preparation
#
# @!attribute definition
#   @return [String]
#     a definition describing the preparation
#
class PreparationType < ApplicationRecord
  include Housekeeping::Users
  include Housekeeping::Timestamps
  include Shared::Tags
  include Shared::SharedAcrossProjects
  include Shared::HasPapertrail
  include Shared::IsData

  has_many :collection_objects, dependent: :restrict_with_error
  validates_presence_of :name, :definition

  validates_uniqueness_of :name

end
