# A GeographicAreaType is a string describing the (generally local) name for the (generally) political designation of
# the area.
#
# @!attribute name
#   @return [String]
#   The name of the geographic area type.
#
class GeographicAreaType < ActiveRecord::Base
  include Housekeeping::Users
  include Shared::IsData

  has_many :geographic_areas, inverse_of: :geographic_area_type

  validates :name, uniqueness: true, presence: true

  COUNTRY_LEVEL_TYPES = ['Country', 'Governorate']
  STATE_LEVEL_TYPES   = ['State', 'Province', 'District', 'Prefecture', 'Region',
                         'Territory', 'Republic', 'Area', 'Oblast', 'Krai']
  COUNTY_LEVEL_TYPES  = ['County', 'Parish', 'Borough', 'Canton', 'Department', 'Raion']
end
