class GeographicAreasGeographicItem < ActiveRecord::Base
  belongs_to :geographic_area
  belongs_to :geographic_item
end
