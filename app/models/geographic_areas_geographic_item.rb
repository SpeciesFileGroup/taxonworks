# A GeographicAreaGeographicItem is an assertion that a 
# GeographicArea was defined by a shape (GeographicItem) according to some source. 
# The assertion may be bound by time.
#
# @!attribute data_origin 
#   @return [String]
#     the origin of this shape associations, take from SFGs /gaz data
# @!attribute origin_gid 
#   @return [String]
#     the gid (row number) taken from the shape table from the source
# @!attribute date_valid_from
#   @return [String]
#     the verbatim value taken from the source data as to when this shape was first valid for the associated GeographicArea (name) 
# @!attribute date_valid_to
#   @return [String]
#     the verbatim data value taken from the source data as to when this shape was last valid for the associated GeographicArea (name) 
class GeographicAreasGeographicItem < ActiveRecord::Base
  belongs_to :geographic_area, inverse_of: :geographic_areas_geographic_items
  belongs_to :geographic_item, inverse_of: :geographic_areas_geographic_items

  validates :geographic_area, presence: true

  unless ENV['NO_GEO_VALID'] 
    validates :geographic_item, presence: true  
  end
end
