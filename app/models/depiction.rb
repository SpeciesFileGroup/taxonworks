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
  include Shared::DwcOccurrenceHooks
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
  validates_uniqueness_of :image_id, scope: [:depiction_object_type, :depiction_object_id] #, allow_nil: true, if: Proc.new {|n| !n.sled_image_id.nil?}

  before_validation :normalize_image

  # Deprecated for unify() functionality
  after_update :remove_media_observation2, if: Proc.new {|d| d.depiction_object_type_previously_was == 'Observation' && d.depiction_object.respond_to?(:type_was) && d.depiction_object.type_was == 'Observation::Media' }
  after_destroy :remove_media_observation, if: Proc.new {|d| d.depiction_object_type == 'Observation' && d.depiction_object.type == 'Observation::Media' }

  # TODO: almost certainly deprecate
  after_update :destroy_image_stub_collection_object, if: Proc.new {|d| d.depiction_object_type_previously_was == 'CollectionObject' && d.depiction_object_type == 'CollectionObject' }

  # !? This is purposefully redundant with Shared::DwcOccurrencHooks without
  # constraints because that version doesn't catch `saved_changes?` in specs.
  # Maybe because specs pass objects. Maybe because other hooks?
  after_save_commit :update_dwc_occurrence, unless: :no_dwc_occurrence

  def normalize_image
    if o = Image.where(project_id: Current.project_id, image_file_fingerprint: image.image_file_fingerprint).first
      self.image = o
    end
  end

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

  def dwc_occurrences
    co = DwcOccurrence
      .joins("JOIN depictions d on d.depiction_object_id = dwc_occurrence_object_id AND d.depiction_object_type = 'CollectionObject'")
      .where(d: {id:}, dwc_occurrences: {dwc_occurrence_object_type: 'CollectionObject'})
      .distinct

    fo = DwcOccurrence
      .joins("JOIN depictions d on d.depiction_object_id = dwc_occurrence_object_id AND d.depiction_object_type = 'FieldOccurrence'")
      .where(d: {id:}, dwc_occurrences: {dwc_occurrence_object_type: 'FieldOccurrence'})
      .distinct

    ::Queries.union(DwcOccurrence, [co, fo])
  end

  private

  #  Deprecate for calls to unify() ?!
  def remove_media_observation2
    if v = depiction_object_id_previously_was
      o = Observation::Media.find(v)
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

  def destroy_image_stub_collection_object
    if sqed_depiction.present?
      if v = depiction_object_id_previously_was
        o = CollectionObject.find(v)
        if o.is_image_stub?
          o.destroy!
        end
      end
    end
  end

end
