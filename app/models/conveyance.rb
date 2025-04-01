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
# @!attribute start_time
#   @return [Numeric]
#     in seconds

# @!attribute end_time
#   @return [Numeric]
#     in seconds
#     
class Conveyance < ApplicationRecord
  include Housekeeping
  include Shared::Citations
  include Shared::Notes
  include Shared::Tags
  include Shared::PolymorphicAnnotator
  include Shared::IsData
  polymorphic_annotates(:conveyance_object)

  acts_as_list scope: [:project_id, :conveyance_object_type, :conveyance_object_id]

  belongs_to :sound, inverse_of: :conveyances
  belongs_to :conveyance_object, polymorphic: true

  validates_presence_of :conveyance_object, :sound

  validates_uniqueness_of :sound_id, scope: [:conveyance_object_type, :conveyance_object_id]

  validate :end_time_after_start

  accepts_nested_attributes_for :sound

  protected

  def end_time_after_start
    if (start_time && end_time) && start_time > end_time
      errors.add(:end_time, 'must be after start time')
    end
  end 

end

