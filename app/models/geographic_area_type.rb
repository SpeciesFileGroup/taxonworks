# A GeographicAreaType is a string describing the (generally local) name for the (generally) political designation of
# the area.
#
# @!attribute name
#   @return [String]
#   The name of the geographic area type.
#
class GeographicAreaType < ApplicationRecord
  include Housekeeping::Users
  include Housekeeping::Timestamps
  include Shared::IsData
  include Shared::IsApplicationData

  COUNTRY_LEVEL_TYPES = %w(Country Governorate).freeze
  STATE_LEVEL_TYPES   = %w(State Province District Prefecture Region Territory Republic Area Oblast Krai).freeze
  COUNTY_LEVEL_TYPES  = %w(County Parish Borough Canton Department Raion).freeze

  has_many :geographic_areas, inverse_of: :geographic_area_type

  validates :name, uniqueness: true, presence: true
end
