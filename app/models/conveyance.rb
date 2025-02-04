# A depiction is the linkage between an sound and a data object.  For example
# an Sound may convey some CollectionObject or OTU.
#
# @!attribute sound_id
#   @return [Integer]
#     the id of the Sound being conveyed
#
# @!attribute conveyance_object_type
#   @return [String]
#     the type of object being conveyed
#
# @!attribute conveyance_object_id
#   @return [Integer]
#     the id of the object being conveyed
#
class Conveyance < ApplicationRecord
  include Housekeeping
  include Shared::Citations
  include Shared::Notes
  include Shared::Tags
  include Shared::IsData
  include Shared::PolymorphicAnnotator
  polymorphic_annotates(:conveyance_object)

  acts_as_list scope: [:project_id, :conveyance_object_type, :conveyance_object_id]

  belongs_to :sound, inverse_of: :conveyances
  belongs_to :conveyance_object, polymorphic: true

  validates_presence_of :conveyance_object
  validates_uniqueness_of :sound_id, scope: [:conveyance_object_type, :conveyance_object_id]

  accepts_nested_attributes_for :sound

end

