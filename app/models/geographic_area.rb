class GeographicArea < ActiveRecord::Base
  belongs_to :geographic_item
  belongs_to :geographic_area_type
end
