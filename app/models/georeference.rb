=begin
# TODO: Move these into YARD doc format as in the example below
    geographic_item_id [integer]
    collecting_event_id [integer]
    error_radius (meters [reflects horizontal]) [real/decimal]
    error_depth (meters, [reflects vertical]) [real/decimal]
    error_geographic_item_id (restricted to type polygon [reflects horizontal]) [integer]
    type [string, references a class name that defines the method used]
    source_id [integer]
    position [integer
    request [string]

# @!attribute geographic_item_id 
#   @return [Integer] 
#    the id of a GeographicItem the represents the (non-error) representation of this georeference defintion  
# @!attribute collecting_event_id 
#   @return [Integer] 
#    the id of a CollectingEvent
# ....
=end
class Georeference < ActiveRecord::Base

  # 'belongs_to' indicates that there is a record ID for this type of object (collecting_event) in *this* table, which
  # is used to find the object we want, 'collecting_event_id' is the column name, and refers to the 'collecting_events'
  # table
  belongs_to :collecting_event

  # this represents a GeographicItem, but has a name (error_geographic_item) which is *not* the name of the column used in the table;
  # therefore, we need to tell it *which* table, and what to use to address the record we want
  belongs_to :error_geographic_item, class_name: 'GeographicItem', foreign_key: :error_geographic_item_id

  belongs_to :geographic_item

  validate :proper_data_is_provided

  protected
  def proper_data_is_provided
    case
    when GeographicItem.find(geographic_item_id) == nil
      errors.add(:georef, 'ID must be from item of class Geographic_Item.') # THis isn't necessary, we'll have an index on the db
      # when CollectingEvent.find(collecting_event_id) == nil
      #  errors.add(:georef, 'ID must be from item of class CollectingEvent.')
      # when GeographicItem.find(error_geographic_item_id).object.geometry_type.type_name != 'Polygon'
      #  errors.add(:georef, 'ID must be from item of class Geographic_Item of type \'POLYGON\'.')
      # when GeoreferenceType.find(type).to_s != 'Georeference::GeoreferenceType'
      #  errors.add(:georef, 'type must be of class Georeference::GeoreferenceType.')
    else
      true
    end
  end
end
