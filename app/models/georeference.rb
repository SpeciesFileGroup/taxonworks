class Georeference < ActiveRecord::Base
  include Housekeeping::Users

# Contains information about a location on the face of the Earth, consisting of:
#
# @!attribute geographic_item_id
#   @return [Integer]
#    the id of a GeographicItem that represents the (non-error) representation of this georeference definition
# @!attribute collecting_event_id
#   @return [Integer]
#    the id of a CollectingEvent that represents the event of this georeference definition
# @!attribute error_radius
#   @return [Integer]
#    the distance in meters of the radius of the area of horizontal uncertainty of the accuracy of the location of this georeference definition
# @!attribute error_depth
#   @return [Integer]
#    the distance in meters of the radius of the area of vertical uncertainty of the accuracy of the location of this georeference definition
# @!attribute error_geographic_item_id
#   @return [Integer]
#    the id of a GeographicItem that represents the (error) representation of this georeference definition
# @!attribute type
#   @return [String]
#    the type name of the this georeference definition
# @!attribute source_id
#   @return [Integer]
#    the id of the source of this georeference definition
# @!attribute position
#   @return [Integer]
#    the position of this georeference definition
# @!attribute request
#   @return [String]
#    the text of the GeoLocation request (::GeoLocate), or the verbatim data (VerbatimData)

#  https://groups.google.com/forum/#!topic/rgeo-users/lMCr0mOt1F0
# TODone: Some of the GADM polygons seem to violate shapefile spec for *some* reason (not necessarily those stated in the above group post). As a possible remedy, adding ":uses_lenient_multi_polygon_assertions => true"
# TODone: This is also supposed to be the default factory (in fact, the *only* factory), but that does not seem to be the case. See lib/tasks/build_geographic_areas.rake

  FACTORY = RGeo::Geographic.projected_factory(srid:                    4326,
                                               projection_srid:         4326,
                                               projection_proj4:          '+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs',
                                               uses_lenient_assertions: true,
                                               has_z_coordinate:        true)
=begin
  FACTORY = ::RGeo::Geos.factory(native_interface:                      :ffi,
                                 uses_lenient_multi_polygon_assertions: true,
                                 srid:                                  4326,
                                 has_z_coordinate:                      true)
=end

  # 'belongs_to' indicates that there is a record ID for this type of object (collecting_event) in *this* table, which
  # is used to find the object we want, 'collecting_event_id' is the column name, and refers to the 'collecting_events'
  # table
  belongs_to :collecting_event

  # this represents a GeographicItem, but has a name (error_geographic_item) which is *not* the name of the column used in the table;
  # therefore, we need to tell it *which* table, and what to use to address the record we want
  belongs_to :error_geographic_item, class_name: 'GeographicItem', foreign_key: :error_geographic_item_id

  belongs_to :geographic_item

  accepts_nested_attributes_for :geographic_item, :error_geographic_item

  validate :proper_data_is_provided

  protected

  def proper_data_is_provided
    # case
    # when GeographicItem.find(geographic_item_id) == nil
    #  errors.add(:georef, 'ID must be from item of class Geographic_Item.') # THis isn't necessary, we'll have an index on the db
    # when CollectingEvent.find(collecting_event_id) == nil
    #  errors.add(:georef, 'ID must be from item of class CollectingEvent.')
    # when GeographicItem.find(error_geographic_item_id).geo_object.geometry_type.type_name != 'Polygon'
    #  errors.add(:georef, 'ID must be from item of class Geographic_Item of type \'POLYGON\'.')
    # when GeoreferenceHash[*arr]Type.find(type).to_s != 'Georeference::GeoreferenceType'
    #  errors.add(:georef, 'type must be of class Georeference::GeoreferenceType.')
    # else
    true
    # end
  end
end
