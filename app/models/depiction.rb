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
# @!attribute svg_clip
#   @return [xml, nil]
#     a clipping mask to isolate some portion of the picture
#
# @!attribute svg_view_box
#   @return [String, nil]
#     sets the clipping box, identical dimensions to clip for rectangles
#
# @!attribute is_metadata_depiction
#   @return [Boolean, nil]
#      If true then this depiction depicts data that describes the entity, rather than the entity itself.
#      For example, a CollectionObject depiction of a insect, vs. a picture of some text that says "the specimen is blue"
#
# @!attribute sled_image_id
#   @return [Integer]
#      If present this depiction was derived from sled
#
# @!attribute sled_image_x_position
#   @return [Integer]
#      Not null if sled_image_is present.  The column (top left 0,0) derived from
#
# @!attribute sled_image_y_position
#   @return [Integer]
#      Not null if sled_image_is present.  The row (top left 0,0) derived from
#
class Depiction < ApplicationRecord
  include Housekeeping
  include Shared::Tags
  include Shared::DataAttributes
  include Shared::IsData
  include Shared::PolymorphicAnnotator
  polymorphic_annotates(:depiction_object)

  acts_as_list scope: [:project_id, :depiction_object_type, :depiction_object_id]

  belongs_to :image, inverse_of: :depictions
  belongs_to :sled_image, inverse_of: :depictions
  has_one :sqed_depiction, dependent: :destroy

  accepts_nested_attributes_for :image
  accepts_nested_attributes_for :sqed_depiction, allow_destroy: true

  validates_presence_of :depiction_object
  validates_uniqueness_of :sled_image_id, scope: [:project_id, :sled_image_x_position, :sled_image_y_position], allow_nil: true, if: Proc.new {|n| !n.sled_image_id.nil?}

  after_update :remove_media_observation2, if: Proc.new {|o| o.depiction_object.type == 'Observation::Media' }
  after_destroy :remove_media_observation, if: Proc.new {|o| o.depiction_object.type == 'Observation::Media' }

  def from_sled?
    !sled_image_id.nil?
  end

  def sled_extraction_path(size = :thumb)
    if from_sled?
      x, y, w, h = svg_view_box.split(' ')

      box_width, box_height = nil, nil
      case size
      when :thumb, :medium
        box_width = Image::DEFAULT_SIZES[size][:width]
        box_height = Image::DEFAULT_SIZES[size][:height]
      when :original
        box_width = w.to_i
        box_height = h.to_i
      end

      "#{image_id}/scale_to_box/#{x.to_i}/#{y.to_i}/#{w.to_i}/#{h.to_i}/#{box_width}/#{box_height}"
    else
      raise 'This is not a sled derived depiction'
    end
  end

  private

  def remove_media_observation2
    if v = previous_changes['depiction_object_id']
      o = Observation::Media.find(v[0])
      if o.depictions.size == 0
        o.destroy!
      end
    end
  end

  def remove_media_observation
    if depiction_object.depictions.size == 0
      depiction_object.destroy!
    end
  end

end
