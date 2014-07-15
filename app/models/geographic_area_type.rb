# A GeographicAreaType is a string describing the (generally local) name for the (generally) political designation of
# the area.
#
# @!attribute name
#   @return [String]
#     The name of the geographic area type.
#
class GeographicAreaType < ActiveRecord::Base
  include Housekeeping::Users

  has_many :geographic_areas, inverse_of: :geographic_area_type

  validates_presence_of :name
end
