# A depiction is the linkage between an image and a data object.  For example
# an image may depiction a ColletingEvent, CollectionObject, or OTU.
#
# @!attribute depiction_object_type
#   @return [String]
#     the type of object being depicted, a TW class that can be depicted (e.g. CollectionObject, CollectingEvent)
#
# @!attribute depiction_object_id
#   @return [Integer]
#     the id of the object being depicted
#
# @!attribute image_id
#   @return [Integer]
#     the id of the image that stores the depiction
#
# @!attribute project_id
#   @return [Integer]
#     the project ID
#
class Depiction < ApplicationRecord
  # TODO: add position scoping

  include Housekeeping
  include Shared::Tags
  include Shared::DataAttributes
  include Shared::IsData
  include Shared::PolymorphicAnnotator
  polymorphic_annotates(:depiction_object)

  acts_as_list scope: [:depiction_object_type, :depiction_object_id]

  belongs_to :image, inverse_of: :depictions

  has_one :sqed_depiction, dependent: :destroy

  validates_presence_of :depiction_object

  accepts_nested_attributes_for :image
  accepts_nested_attributes_for :depiction_object
end
