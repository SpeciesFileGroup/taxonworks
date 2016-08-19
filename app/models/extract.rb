class Extract < ActiveRecord::Base
  include Housekeeping
  include Shared::IsData

  validates_presence_of :quantity_value 
  validates_presence_of :quantity_unit
  validates_presence_of :quantity_concentration 
  validates_presence_of :verbatim_anatomical_origin 
  validates_presence_of :year_made 
  validates_presence_of :month_made 
  validates_presence_of :day_made
end
