class CollectingEvent < ActiveRecord::Base
  belongs_to :geographic_area
  belongs_to :confidence
end
