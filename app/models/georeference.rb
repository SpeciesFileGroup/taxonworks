class Georeference < ActiveRecord::Base

  belongs_to :collecting_event

  has_one :geographic_item

  validate :proper_data_is_provided

  protected
  def proper_data_is_provided
=begin
    geographic_item_id [integer]
    collecting_event_id [integer]
    error_radius (meters [reflects horizontal]) [real/decimal]
    error_depth (meters, [reflects vertical]) [real/decimal]
    error_geographic_item_id (restricted to type polygon [reflects horizontal]) [integer]
    type [string, references a class name that defines the method used]
    source_id [integer]
    position [integer]
=end

    case
      when GeographicItem.find(geographic_item_id) == nil
        errors.add(:georef, 'ID must be from item of class Geographic_Item.')
      when CollectingEvent.find(collecting_event_id) == nil
        errors.add(:georef, 'ID must be from item of class CollectingEvent.')
      when GeographicItem.find(error_geographic_item_id).geometry_type.type_name != 'Polygon'
        errors.add(:georef, 'ID must be from item of class Geographic_Item of type \'POLYGON\'.')
      else
        true
    end
  end
end
