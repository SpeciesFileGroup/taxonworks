# An extract is the quantified physical entity that originated from a collection object

class Extract < ActiveRecord::Base
  include Housekeeping
  include Shared::IsData
  include Shared::OriginRelationship
 
  is_origin_for 'Sequence', 'Extract'

  validates_presence_of :quantity_value 
  validates_presence_of :quantity_unit
  
  validates :year_made, date_year: { allow_blank: false }
  validates :month_made, date_month: { allow_blank: false }
  validates :day_made, date_day: { allow_blank: false }

end
