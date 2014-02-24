class GeographicAreaType < ActiveRecord::Base
  include Housekeeping::Users

  has_many :geographic_areas, inverse_of: :geographic_area_type

  validates_presence_of :name
end
